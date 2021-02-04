//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "ModeIIKFieldDirichletBC.h"

registerMooseObject("raccoonApp", ModeIIKFieldDirichletBC);

InputParameters
ModeIIKFieldDirichletBC::validParams()
{
  InputParameters params = NodalBC::validParams();
  params.addClassDescription(
      "applies the Dirichlet BC conforming with the analytical solution of a Mode-I crack. The "
      "crack is assumed to be emanating from the origin. For $t \\in [0, 1]$ the BC ramps up "
      "linearly to match the initial crack tip position, and for $t \\in [1, \\infty)$, the crack "
      "tip advances to the right with a velocity of v");
  params.addParam<RealVectorValue>(
      "initial_crack_tip_position", RealVectorValue(0, 0, 0), "initial crack tip position");
  params.addRequiredParam<unsigned int>("component", "0 for x, 1 for y");
  params.addRequiredParam<Real>("Gc", "energy release rate");
  params.addRequiredParam<Real>("E", "Young's modulus");
  params.addRequiredParam<Real>("nu", "Poisson's ratio");
  //params.addRequiredParam<Real>("K1", "Stress Intensity Factor");
  params.addRequiredParam<FunctionName>("K1", " Mode 1 Stress Intensity Factor");
  params.addRequiredParam<FunctionName>("K2", " Mode 2 Stress Intensity Factor");
  return params;
}

ModeIIKFieldDirichletBC::ModeIIKFieldDirichletBC(const InputParameters & parameters)
  : NodalBC(parameters),
    _c(getParam<RealVectorValue>("initial_crack_tip_position")),
    _component(getParam<unsigned int>("component")),
    _Gc(getParam<Real>("Gc")),
    _E(getParam<Real>("E")),
    _nu(getParam<Real>("nu")),
    //_K1(getParam<Real>("K1")),
    _K1(getFunction("K1")),
    _K2(getFunction("K2")),
    _K(3 - 4 * _nu),
    _mu(_E / 2 / (1 + _nu))
{
}

Real
ModeIIKFieldDirichletBC::computeQpResidual()
{
  RealVectorValue c = _c;
  Real x = (*_current_node)(0) - c(0);
  Real y = (*_current_node)(1) - c(1);
  Real theta = std::atan2(y, x);
  Real r = std::sqrt(x * x + y * y);
  //Real K1 = std::sqrt(_E * _Gc / (1 - _nu * _nu));
  Real K1 = _K1.value(_t,*_current_node);
  Real K2 = _K2.value(_t,*_current_node);

  //u1 is the contribuition from mode 1
  Real u1 = K1 / 2 / _mu * std::sqrt(r / 2 / M_PI) * (_K - std::cos(theta));
  //u2 for mode 2
  Real u2 = K2 / 2 / _mu * std::sqrt(r / 2 / M_PI);
  if (_component == 0) {
    u1 *= std::cos(theta / 2);
    u2 = u2 * std::sin(theta / 2)*(_K + 2 + std::cos(theta));
  }
  if (_component == 1){
    u1 *= std::sin(theta / 2);
    u2 = -u2 * std::cos(theta / 2)*(_K - 2 + std::cos(theta));
  }
  Real u = u1 + u2;
  return _u[_qp] - u;
}
