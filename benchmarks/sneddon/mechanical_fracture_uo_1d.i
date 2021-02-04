E = 1
nu = 0
Gc = 1e-2
l = 0.1
psic = 0
k = 1e-6
dc = 1

[Problem]
  type = FixedPointProblem
[]

# [Mesh]
#   type = GeneratedMesh
#   dim = 1
#   nx = 40000
#   xmin = -5
#   xmax = 5
# []

[Mesh]
 [./gmg]
  type = GeneratedMeshGenerator
  dim = 1
  nx = 10000
  xmin = -5
  xmax = 5
 [../]
 [./middle_nodes]
  type = BoundingBoxNodeSetGenerator
  input = 'gmg'
  new_boundary = middle_nodes
  bottom_left = '-0.001 0 0'
  top_right = '0.001 0 0'
 [../]
[]

[Variables]
  [./disp_x]
  [../]
  [./d]
  [../]
[]

[AuxVariables]
  [./bounds_dummy]
  [../]
[]

[UserObjects]
  [./E_driving]
    type = ADFPIMaterialPropertyUserObject
    mat_prop = 'E_el_active'
  [../]
  [./pressure_uo]
    type = ADFPIMaterialPropertyUserObject
    mat_prop = 'p'
  [../]
[]

[Bounds]
  [./irreversibility]
    type = VariableOldValueBoundsAux
    variable = 'bounds_dummy'
    bounded_variable = 'd'
    bound_type = lower
  [../]
  [./upper]
    type = ConstantBoundsAux
    variable = 'bounds_dummy'
    bounded_variable = 'd'
    bound_type = upper
    bound_value = 1
  [../]
[]

[Kernels]
  [./solid_x]
    type = ADStressDivergenceTensors
    variable = 'disp_x'
    component = 0
    displacements = 'disp_x'
  [../]
  [./pressure_body_force_x]
    type = ADPressurizedCrack
    variable = 'disp_x'
    d = 'd'
    pressure_mat = 'p'
    component = 0
  [../]
  [./pff_diff]
    type = ADPFFDiffusion
    variable = 'd'
  [../]
  [./pff_barrier]
    type = ADPFFBarrier
    variable = 'd'
  [../]
  [./pff_react]
    type = ADPFFReaction
    variable = 'd'
    driving_energy_uo = 'E_driving'
    lag = false
  [../]
  [./pff_pressure]
    type = ADPFFPressure
    variable = 'd'
    pressure_uo = 'pressure_uo'
    displacements = 'disp_x'
  [../]
[]

[BCs]
  [./xfix]
    type = DirichletBC
    variable = 'disp_x'
    boundary = 'left right'
    value = 0
  [../]
  # [./damage]
  #   type = DirichletBC
  #   variable = 'd'
  #   boundary = 'middle_nodes'
  #   value = 1
  # [../]
[]

[ICs]
  [./d]
    type = BrittleDamageIC
    variable = d
    bandwidth_multiplier = 10
    d0 = 1.0
    l = ${l}
    x1 = '0 1e-3'
    y1 = '0 0'
    z1 = '0 0'
    x2 = '0 1e-3'
    y2 = '0 0'
    z2 = '0 0'
  [../]
[]

[Materials]
  [./pressure]
    type = ADGenericFunctionMaterial
    prop_names = 'p'
    prop_values = '1e-2'
  [../]
  [./elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ${E}
    poissons_ratio = ${nu}
  [../]
  [./strain]
    type = ADComputeSmallStrain
    displacements = 'disp_x'
  [../]
  [./stress]
    type = SmallStrainDegradedElasticPK2Stress_NoSplit
    d = 'd'
    d_crit = ${dc}
  [../]
  [./bulk]
    type = GenericConstantMaterial
    prop_names = 'phase_field_regularization_length energy_release_rate critical_fracture_energy'
    prop_values = '${l} ${Gc} ${psic}'
  [../]
  [./local_dissipation]
    type = QuadraticLocalDissipation
    d = 'd'
  [../]
  [./fracture_properties]
    type = FractureMaterial
    local_dissipation_norm = 2
  [../]
  [./degradation]
    type = QuadraticDegradation
    d = 'd'
    residual_degradation = ${k}
  [../]
  [./elastic_energy]
    type = ElasticEnergyDensity
  [../]
[]

[Executioner]
  type = FixedPointTransient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -sub_pc_type -ksp_max_it -ksp_gmres_restart -sub_pc_factor_levels -snes_type'
  petsc_options_value = 'asm      ilu          200         200                0                     vinewtonrsls'
  line_search = none
  dt = 1e-4
  end_time = 1e-4

  nl_abs_tol = 1e-09
  nl_rel_tol = 1e-09

  automatic_scaling = true
  compute_scaling_once = false

  fp_max_its = 100
  fp_tol = 1e-06
  accept_on_max_fp_iteration = true
[]

[Postprocessors]
  [./helmholtz_energy]
    type = HelmholtzEnergy
    d = d
    pressure_mat = 'p'
    fracture_energy_name = 'fracture_energy'
  [../]
  [./fracture_energy]
    type = FractureEnergy
    d = d
  [../]
[]

[Outputs]
  print_linear_residuals = false
  [./exodus]
    type = Exodus
    file_base = '1d_nodec_fine'
  [../]
  [./console]
    type = Console
    outlier_variable_norms = false
  [../]
[]
