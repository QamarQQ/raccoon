// Gmsh project created on Fri Jul 10 19:56:12 2020

L = 1;
R = 0.50;
h = 0.02;
H = 0.02;
sq = 0.70710678118;

Point(1) = {-1.5*L, -1.5*L, 0, H};
Point(2) = {-1.5*L,  1.5*L, 0, h};
Point(3) = { 1.5*L,  1.5*L, 0, h};
Point(4) = { 1.5*L, -1.5*L, 0, H};
Point(5) = { 0,  0, 0, H};
Point(6) = {-sq*R,  sq*R, 0, h};
Point(7) = { sq*R, -sq*R, 0, h};
Point(8) = { sq*R,  sq*R, 0, h};
Point(9) = {-sq*R, -sq*R, 0, h};

Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,1};
Circle(5) = {6,5,8};
Circle(6) = {8,5,7};
Circle(7) = {7,5,9};
Circle(8) = {9,5,6};

Line Loop(1) = {1, 2, 3, 4};
Curve Loop(2) = {5,6,7,8};
Plane Surface(2) = {1, 2};

out[] = Extrude {0, 0, 0.01} {Surface{2}; Layers{1}; Recombine;};

Physical Volume("all") = {1};
Physical Surface("top") = {25};
Physical Surface("bottom") = {33};
Physical Surface("left") = {21};
Physical Surface("right") = {29};
Physical Surface("circle") = {37,41,45,49};

