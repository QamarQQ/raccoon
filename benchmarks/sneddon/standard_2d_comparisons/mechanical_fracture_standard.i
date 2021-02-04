E = 1
nu = 0.2

[Problem]
  type = FixedPointProblem
[]

[Mesh]
  type = FileMesh
  file = 'meshes/sharp_initial_crack/geo.msh'
  construct_side_set_from_node_set = true
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
[]

[Kernels]
  [./solid_x]
    type = ADStressDivergenceTensors
    variable = 'disp_x'
    component = 0
    displacements = 'disp_x disp_y'
  [../]
  [./solid_y]
    type = ADStressDivergenceTensors
    variable = 'disp_y'
    component = 1
    displacements = 'disp_x disp_y'
  [../]
[]

[BCs]
  [./xfix]
    type = DirichletBC
    variable = 'disp_x'
    boundary = 'top bottom left right'
    value = 0
  [../]
  [./yfix]
    type = DirichletBC
    variable = 'disp_y'
    boundary = 'top bottom left right'
    value = 0
  [../]
  # [./pressure_load]
  #   type =
  # [../]
  [./Pressure]
    [./crack]
      boundary = 'crack'
      factor = 1e-3
      displacements = 'disp_x disp_y'
    [../]
  [../]
[]


[Materials]
  [./pressure]
    type = ADGenericFunctionMaterial
    prop_names = 'p'
    prop_values = '1e-3'
  [../]
  [./elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ${E}
    poissons_ratio = ${nu}
  [../]
  [./strain]
    type = ADComputeSmallStrain
    displacements = 'disp_x disp_y'
  [../]
  [./stress]
    type = ADComputeLinearElasticStress
  [../]
[]

[Executioner]
  type = FixedPointTransient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -sub_pc_type -ksp_max_it -ksp_gmres_restart -sub_pc_factor_levels -snes_type'
  petsc_options_value = 'lu      ilu          200         200                0                     vinewtonrsls'
  dt = 1e-4
  end_time = 1e-4

  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-8

  automatic_scaling = true
  compute_scaling_once = false

  fp_max_its = 100
  fp_tol = 1e-06
  accept_on_max_fp_iteration = true
[]

[Outputs]
  print_linear_residuals = false
  [./exodus]
    type = Exodus
    file_base = 'sharp_initial'
  [../]
  [./console]
    type = Console
    outlier_variable_norms = false
  [../]
[]
