//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#pragma once

#include "Material.h"
#include "Function.h"

class VariableFractureMaterial : public Material
{
public:
  static InputParameters validParams();

  VariableFractureMaterial(const InputParameters & parameters);

protected:
  virtual void initQpStatefulProperties() override;
  virtual void computeQpProperties() override;

  /// energy release rate
  const MaterialProperty<Real> & _Gc;

  /// length scale in the fracture surface energy density
  const Function & _L;

  /// norm of the local dissipation function
  const Function & _w_norm;

  /// interface coefficient in Allen-Cahn equation
  MaterialProperty<Real> & _kappa;

  /// interface coefficient at the previous time step
  const MaterialProperty<Real> & _kappa_old;

  /// Mobility in Allen-Cahn equation
  MaterialProperty<Real> & _M;

  /// Mobility at the previous time step
  const MaterialProperty<Real> & _M_old;
};
