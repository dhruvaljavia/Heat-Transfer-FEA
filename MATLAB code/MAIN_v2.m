clc; clear; close all

% Defined parameters (Al 5052)
t = 0.04*0.0254; % thickness of Al plate (m)(actual plate thickness)
w = 0.09; % width of plate (m)(from Onshape)

k = 138; % thermal conductivity (W/m.K)
rho = 2680; % density (kg/m3)
cp = 890; % specific heat capacity (J/Kg.K)

h = 50; % convective heat transfer coefficient (W/m2/K)
Q_dot = -0.5; % heat generation (W)
Tb = 25; % Edge temperature Dirichlet BC (degC)
T_init = 25; % Initial temp (in deg. C)
T_amb = 0; % Ambient temperature (water bath)(degC)

immersion = 20; % Immersion depth of plate in water bath (in mm)
dim = 2; % Dimension of domain
t_final = 180; % Transient time interval (in sec.)
dt = 5; % Temporal discretization (in sec.)

% Simulation knobs
isTransient = 1;
isDirichletBC = 0;
isConvection = 1;
anim_speed = 0.1;

% Calculated parameters
q_dot = Q_dot/(immersion/1000*w*t); % Volumetric heat generation (W/m3)

% Generating mesh
gm = importGeometry("Al_plate_fractal.stl");
model = femodel(Geometry=gm);
model = generateMesh(model, GeometricOrder="linear", Hmax=3);
X = model.Geometry.Mesh.Nodes/1000;                             % Matrix of nodes : (x,y) coordinates (in m) x node index
LV = model.Geometry.Mesh.Elements;  
LG = LV;                                                        % Local-to-Global matrix : elements in column, basis function in rows, global basis function index as values

% Calculating EtaG and G_arr
EtaG = findNodes(model.Geometry.Mesh, "region", "Edge", [64 47 31]);    % nodes where Tb is present / constrained nodes
G_arr = ones(1,length(EtaG))*Tb;                                % array of Tb


% Finding nodes where heat generation occurs
N_gen = findNodes(model.Mesh,"box",[-50 50], [-120 (-110+immersion)]);

% Assembling K, F and M
nod = size(X,2); % # of nodes
nel = size(LG,2); % # of elements
nbasis = size(LG,1); % # of basis functions in an elements
K = zeros(nod,nod); 
F = zeros(nod,1);
M = zeros(nod,nod);

for iel = 1:nel
    % setting the local data
    lge = LG(:,iel); % global basis function indices for the 3 local basis func in a specific element
    xe(1:dim,1:nbasis) = X(:,lge(:)); % Matrix having (x,y) coordinates of 3 nodes of an element

    % computing element K, F and M
    Ke_mat = Ke(xe, k);
    Fe_vect = Fe(xe, q_dot);
    Me_mat = Me(xe, rho, cp);
    
    % assembly, from local to global
    K(lge,lge) = K(lge,lge) + Ke_mat;
    if all(ismember(lge, N_gen))
        F(lge) = F(lge) + Fe_vect;
    end
    M(lge,lge) = M(lge,lge) + Me_mat;
end

if isDirichletBC == 1
    ng = length(EtaG); % # of constrained nodes
    id = eye(nod); % identity matrix : nod x nod
    for ig=1:ng
        K(EtaG(ig),:) = id(EtaG(ig),:);
        F(EtaG(ig)) = G_arr(ig);
        M(EtaG(ig),:) = 0;
    end
end

% Calculating T distribution
if isTransient == 1
    % Using implicit euler method for time stepping (to have unconditional stability)
    steps = t_final/dt; % # of timesteps
    U = zeros(nod, steps+1);
    U(:,1) = T_init;
    if isDirichletBC == 1
        U(EtaG, 1) = G_arr; % Enforcing dirichlet BC at initial timestep
    end

    for i = 1:steps
        % Updating F to account for changing q_dot (= h(T_node - T_amb)/t) due to convection
        if isConvection == 1
            F = zeros(nod,1);
            for iel = 1:nel
                % setting the local data
                lge = LG(:,iel); % global basis function indices for the 3 local basis func in a specific element
                xe(1:dim,1:nbasis) = X(:,lge(:)); % Matrix having (x,y) coordinates of 3 nodes of an element
            
                if all(ismember(lge, N_gen))
                    % computing element F
                    q_dot = -h*(mean(U(lge,i)) - T_amb)/t;
                    Fe_vect = Fe(xe, q_dot);
                    
                    % assembly, from local to global
                    F(lge) = F(lge) + Fe_vect;
                end
            end
        end

        % Time-stepping
        U(:,i+1) = (M + K*dt)\(M*U(:,i) + F*dt);
    end
else
    u = K\F;
end

% Plotting T distribution
if isTransient == 1
    figure()
    for i = 1:steps+1
        trisurf(LG',X(1,:),X(2,:),U(:,i));
        timeDisp = "Time : " + (i-1)*dt + "s";
        view(2);
        axis equal
        clim([min(min(U)) max(max(U))]);
        cb = colorbar;
        cb.Title.String = 'Temperature (°C)';
        xlabel("x (in m)");
        ylabel("y (in m)");
        title(timeDisp);
        pause(anim_speed);
        if i == 1
            waitforbuttonpress;
        end
    end
else
    figure()
    trisurf(LG',X(1,:),X(2,:),u);
    view(2);
    axis equal
    colorbar;
end

% Helpful plots
figure()
pdegplot(model, "EdgeLabels", "on");
figure()
pdemesh(model)
hold on
plot(model.Mesh.Nodes(1,N_gen),model.Mesh.Nodes(2,N_gen),"or",MarkerFaceColor="g")