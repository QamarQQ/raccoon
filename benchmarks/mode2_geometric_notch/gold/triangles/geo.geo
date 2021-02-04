a = 0.5;
r = 0.0025;

E = 0.05;
e = 0.02;

Point(1) = {-a, -a, 0, E};
Point(2) = {-a, -r, 0, E};
Point(3) = {-r, -r, 0, e};
Point(4) = {-r, 0, 0, e};
Point(5) = {-r, r, 0, e};
Point(6) = {-a, r, 0, E};
Point(7) = {-a, a, 0, E};
Point(8) = {a, a, 0, E};
Point(9) = {a, -a+10*r, 0, e};
Point(10) = {a, -a, 0, e};
Point(11) = {0.4, -a, 0, e};
Point(12) = {0, -0.0025, 0, e};
Point(13) = {0.1, -0.28, 0, e};

Line(1) = {1, 2};
Line(2) = {2, 3};
Circle(3) = {3, 4, 5};
Line(4) = {5, 6};
Line(5) = {6, 7};
Line(6) = {7, 8};
Line(7) = {8, 9};
Line(8) = {9, 10};
Line(9) = {10, 11};
Line(10) = {11, 1};
BSpline(11) = {12, 13, 11};
Line Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

Plane Surface(1) = {1};
Line{11} In Surface {1};

//Mesh.SubdivisionAlgorithm = 2;

out[] = Extrude {0, 0, 0.05} {Surface{1}; Layers{1}; Recombine;};

Physical Volume("all") = {1};
Physical Surface("top") = {46};
Physical Surface("bottom") = {62, 58};
Physical Surface("left") = {42, 26};
Physical Surface("right") = {50, 54};
