function Fe_val = Fe(xe, fe)
    Ae2 =  (xe(1,2)-xe(1,1))*(xe(2,3)-xe(2,1)) - (xe(2,1)-xe(2,2))*(xe(1,1)-xe(1,3));
    Fe_val = Ae2*fe*ones(3,1)/6;
end