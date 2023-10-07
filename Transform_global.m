function Y = Transform_global (C,S,EN)

Y = [C(EN)  S(EN) 0   0; 0   0  C(EN)  S(EN)];

