H = 0.05;
h = 0.002;
l = 1e-3;
L = 4;
c = 0.2143;

Point(1) = {-L/2, -L/2, 0, H};
Point(2) = {-c, 0, 0, h};
Point(3) = {0, -l, 0, h};
Point(4) = {-L/2, L/2, 0, H};
Point(5) = {L/2, L/2, 0, H};
Point(6) = {c, 0, 0, h};
Point(7) = {0, l, 0, h};
Point(8) = {L/2, -L/2, 0, H};

Line(1) = {1, 4};
Line(2) = {4, 5};
Line(3) = {5, 8};
Line(4) = {8, 1};
Line(5) = {2, 3};
Line(6) = {3, 6};
Line(7) = {6, 7};
Line(8) = {7, 2};
//Line(9) = {9, 2};
//Line(10) = {6, 10};

Line Loop(1) = {1, 2, 3, 4};
Line Loop(2) = {5, 6, 7, 8}; 

Plane Surface(1) = {2,1};
//Line{5, 6, 7, 8} In Surface {1};
//Line{6, 8} In Surface {1};
//Line{9, 10} In Surface {1};

Physical Surface("all") = {1};
Physical Line("top") = {2};
Physical Line("bottom") = {4};
Physical Line("left") = {1};
Physical Line("right") = {3};
Physical Line("crack") = {5,6,7,8};

