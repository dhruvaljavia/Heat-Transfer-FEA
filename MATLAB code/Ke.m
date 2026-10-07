function Ke_val = Ke(xe, ke)
    dN = [xe(2,2)-xe(2,3), xe(2,3)-xe(2,1), xe(2,1)-xe(2,2);
        xe(1,3)-xe(1,2), xe(1,1)-xe(1,3), xe(1,2)-xe(1,1)];
    Ae2 = dN(2,3)*dN(1,2) - dN(1,3)*dN(2,2);
    dN = dN/Ae2;
    Ke_val = Ae2/2*ke*(dN'*dN);
end