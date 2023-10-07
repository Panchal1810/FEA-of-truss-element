
function [eps, sigma, ele_f] = postprocessing(E,A,B,T,d,GNN)


eps = B'*T*d(GNN);

sigma = E*eps;

ele_f = sigma*A;