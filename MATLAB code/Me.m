function Me_val = Me(xe, rho, Cp)
    Ae2 = (xe(1,2)-xe(1,1))*(xe(2,3)-xe(2,1)) - (xe(2,1)-xe(2,2))*(xe(1,1)-xe(1,3));
    Ae = Ae2/2;
    Me_val = rho*Cp*Ae/12*[2 1 1; 1 2 1; 1 1 2];
end