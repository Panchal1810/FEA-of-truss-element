
function k_local = Kel_truss(EN,A,E,l,B,T)
%{
DOF_pernode = 1;
DOF_perele = 2;
E = 80*(10^9);
A_0 = 0.1*0.02 ;
A_L = 0.02* 0.01 ;
L = 0.2;


N = 4; % no. of nodes
delx = L/(N-1) ;


x = zeros((N*DOF_pernode),1);
A_x = zeros((N*DOF_pernode),1);

x(1) = 0;
x(N) = L;
A_x(1) = A_0;
A_x(N) = A_L; 

u = zeros((N*DOF_pernode),1);
K_global = zeros ((N*DOF_pernode),(N*DOF_pernode));
r_q = zeros((N*DOF_pernode),1);
r_beta = zeros((N*DOF_pernode),1);



%%%%%%%%%%% applied boundary conditions %%%%%%%%%%
u(1,1) = 0;
%r_beta(1,1) = R1;
r_beta((N*DOF_pernode),1) = 5000 ;
q = 10000 ;



for i=2:N-1

    x(i) = x(i-1) + delx ;
    A_x(i) = A_0 + (x(i)/L)*(A_L - A_0);

end
%}

    
    k_l = E*A*l(EN)*(B*B');

    k_local = T'*k_l*T;

