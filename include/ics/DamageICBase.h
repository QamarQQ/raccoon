//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#pragma once

#include "InitialCondition.h"

class DamageICBase : public InitialCondition
{
public:
  static InputParameters validParams();

  DamageICBase(const InputParameters & parameters);

protected:
  virtual Real dist(const Point & p);
  std::vector<Real> _x1;
  std::vector<Real> _y1;
  std::vector<Real> _z1;
  std::vector<Real> _x2;
  std::vector<Real> _y2;
  std::vector<Real> _z2;
  const Real _d0;
  const Real _l;
};
