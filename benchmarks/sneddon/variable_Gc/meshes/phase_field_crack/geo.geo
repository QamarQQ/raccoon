H = 0.3;
h = 0.004;
l = 2e-2;
L = 4;
c = 0.2;

Point(1) = {-L/2, -L/2, 0, H};
Point(2) = {-5*c, 0, 0, h};
//Point(3) = {-c, -h/8, 0, h};
Point(4) = {-L/2, L/2, 0, H};
Point(5) = {L/2, L/2, 0, H};
Point(6) = {5*c, 0, 0, h};
//Point(7) = {c, -h/8, 0, h};
Point(8) = {L/2, -L/2, 0, H};

//refinement region
Point(15) = {-5*c, l, 0, h};
Point(16) = {-5*c, -l, 0, h};
Point(17) = {5*c, l, 0, h};
Point(18) = {5*c, -l, 0, h};


Line(1) = {1, 4};
Line(2) = {4, 5};
Line(3) = {5, 8};
Line(4) = {8, 1};
Line(5) = {2, 6};
//Line(6) = {3, 7};
Line(7) = {15, 17};
Line(8) = {16, 18};


Line Loop(1) = {1, 2, 3, 4};
//Line Loop(2) = {5, 6, 7, 8}; 


Plane Surface(1) = {1};
Line{5, 7, 8} In Surface {1};
//Line{9, 10} In Surface {1};

Physical Surface("all") = {1};
Physical Line("top") = {2};
Physical Line("bottom") = {4};
Physical Line("left") = {1};
Physical Line("right") = {3};
Physical Line("crack") = {5,6,7,8};

