clc
clear all;
%for this program the inputs are node,conn and isol
% node- Give the co-ordinates of the nodes in the form of a vector
%       for e.g.[x1 y2;x2 y2;x3 y3;so on...]
% conn- This states the connection of the trusses i.e. the connection of
%       the nodes by the trusses
%       for e.g.[1 2;1 3;2 3;2 4;1 4;3 4;3 6;4 5;4 6;3 5;5 6]
%       The starting node of the 1st element is 1 and the end node is 2
%       according to the problem statement
%       Similarly give the start and end nodes for each element
% isol- This is the inverse of the boundary conditions i.e. the no. of dofs
%       possible. For e.g. according to my problem statement, the node 1 is
%       fixed and node 5 can have movement in only X-direction. So
%       according to the problem 1,2 & 10 = 0. So provide the rest of the
%       nodes


%node=input('\nEnter the co-ordinates of the nodes in the vector form:');
%conn=input('\nEnter the start and end nodes of each element in the vector form:');

CCORD=xlsread('truss.xlsx',1,'A1:D5'); %Node number and corresponding cordinates are loaded
NCA=xlsread('truss.xlsx',1,'G1:I5');   % Element number and connected nodes with the elemnts are loaded

%A=input('\nEnter cross-sectional area of the element:');
%E=input('\nEnter modulus of elasticity of the element:');

A = 0.00064516;
E = 2.03395*1e+011;

isol=[3 5 6]; % Free degrees of freedom
constrain = [1 2 4 7 8]; % constrain degree of freedom
alldof = [1 2 3 4 5 6 7 8]; %all dof
% The input from the user ends here

 
NNODES=length(CCORD);
NELEMENTS=length(NCA);  
l = zeros(NELEMENTS,1);
DOFPN=2;          % DOF Every node has 2 dofs.
nnp=DOFPN*NNODES; % Total degree of freedom

%loading condition
F=zeros(nnp,1);   %Initializing force matrix
F(3) = 88964.378;
F(6) = -111205.47;

K=zeros(nnp,nnp); % Intializing stiffness matrix
d=zeros(nnp,1);        %Defines size of the displacemetn matrix
d_f =zeros(NNODES,2);
%e = zeros(NELEMENTS,1);
%sigma = zeros(NELEMENTS,1);
C = zeros(NELEMENTS,1);
S = zeros(NELEMENTS,1);


%% Calculation of length and cosine and sine
for EN=1:NELEMENTS

 l(EN) = ((CCORD(NCA(EN,2),2)-CCORD(NCA(EN,3),2))^2 + (CCORD(NCA(EN,2),3)-CCORD(NCA(EN,3),3))^2)^0.5 ;
 C(EN) = (CCORD(NCA(EN,3),2)-CCORD(NCA(EN,2),2))/(l(EN));
 S(EN) = (CCORD(NCA(EN,3),3)-CCORD(NCA(EN,2),3))/(l(EN));

end


%% Calculation of element stiffness matrix
for EN=1:NELEMENTS
 %EN = 4;
    [B]=BCAL_truss(l,EN);     
    [T]=Transform_global(C,S,EN);
   [ ke ] = Kel_truss(EN,A,E,l,B,T);
      [n1] = NCA(EN,2);
      [n2] = NCA(EN,3);
    % Here, we globalize the global matrix according to the respective node
    % and respective displacement
   GNN=[2*n1-1 2*n1 2*n2-1 2*n2];
   K(GNN,GNN)=K(GNN,GNN)+ke;
end


%% We have got our global matrix. Now we solve the matrices to get the
% displacements at each node
d(isol)=K(isol,isol)\F(isol);
fprintf('\n----------Nodal Displacements----------');
fprintf('\nNo.  X-Direction     Y-Direction');
for i=1:NNODES
    fprintf('\n%5d  %8.3e   %8.3e',i,d(2*i-1),d(2*i));
end


%% Reactions at nodes
f(constrain)=K(constrain,alldof)*d;
fprintf('\n----------Reactions----------');
fprintf('\nNo.  X-Direction     Y-Direction');
for i=1:NNODES
    fprintf('\n%5d  %8.3e   %8.3e',i,f(2*i-1),f(2*i));
end


%% Now we print the strains and stresses
fprintf('\n----------Elemental strain & stress----------');
fprintf('\nNo.  Strain  Stress');
for EN=1:NELEMENTS

      [n1] = NCA(EN,2);
      [n2] = NCA(EN,3);
      GNN=[2*n1-1 2*n1 2*n2-1 2*n2];

     [B]=BCAL_truss(l,EN);     
    [T]=Transform_global(C,S,EN);
     
    [Strain,Stress,force]=postprocessing(E,A,B,T,d,GNN);  
   
   fprintf('\n%5d  %8.3e   %8.3e   %8.3e',EN,Strain,Stress,force);
end


%% plot deform and undeformed structure 

plot(CCORD(:,2),CCORD(:,3),'-or','MarkerSize',10,'LineWidth',2);

hold on


for EN=1:NELEMENTS

    d_f(EN,1)  = CCORD(EN,2) + d(2*EN-1);
    d_f(EN,2)  = CCORD(EN,3) + d(2*EN);
  
   
end

plot(d_f(:,1),d_f(:,2),'--sk','MarkerSize' ,10,'LineWidth',2);

xlabel('x')
ylabel('y')
ylim([-0.4 1.2])
xlim ([-0.2 1.2])

