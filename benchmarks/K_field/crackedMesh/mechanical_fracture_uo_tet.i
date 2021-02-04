E = 2.1e5
nu = 0.3
Gc = 2.7
l = 0.15
psic = 0
k = 1e-6
dc = 1

[Problem]
  type = FixedPointProblem
[]

[Mesh]
  [./gmg]
    type = FileMeshGenerator
    file = 'coarse0.msh'
  [../]
  [./top]
   type = BoundingBoxNodeSetGenerator
   input = 'gmg'
   new_boundary = top
   bottom_left = '-0.501 0.499 0'
   top_right = '0.501 0.501 0'
  [../]
  [./bottom]
   type = BoundingBoxNodeSetGenerator
   input = 'top'
   new_boundary = bottom
   bottom_left = '-0.501 -0.501 0'
   top_right = '0.501 -0.499 0'
  [../]
  [./left]
   type = BoundingBoxNodeSetGenerator
   input = 'bottom'
   new_boundary = left
   bottom_left = '-0.501 -0.501 0'
   top_right = '-0.499 0.501 0'
  [../]
  [./right]
   type = BoundingBoxNodeSetGenerator
   input = 'left'
   new_boundary = right
   bottom_left = '0.499 -0.501 0'
   top_right = '0.501 0.501 0'
  [../]
[]

# [Adaptivity]
#   steps = 1
#   marker = 'box'
#   max_h_level = 3
#   initial_steps = 3
#   stop_time = 1.0e-10
#   [./Markers]
#     [./box]
#       type = BoxMarker
#       bottom_left = '-0.5 -0.04 0'
#       inside = refine
#       top_right = '0.5 0.04 0'
#       outside = do_nothing
#     [../]
#   [../]
# []

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./d]
  [../]
[]

[AuxVariables]
  [./bounds_dummy]
  [../]
  [./fy]
  [../]
  [./stress_xy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[UserObjects]
  [./E_driving]
    type = ADFPIMaterialPropertyUserObject
    mat_prop = 'E_el_active'
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

[AuxKernels]
  [./stress_xy]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = stress_xy
    index_i = 0
    index_j = 1
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
    save_in = 'fy'
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
[]

[BCs]
  [./xdisp]
    type = ModeIIKFieldDirichletBC
    component = 0
    variable = 'disp_x'
    boundary = 'top bottom left right'
    Gc = ${Gc}
    E = ${E}
    nu = ${nu}
    K1 = 0
    K2 = '300*t*1e5'
  [../]
  [./ydisp]
    type = ModeIIKFieldDirichletBC
    component = 1
    variable = 'disp_y'
    boundary = 'top bottom left right'
    Gc = ${Gc}
    E = ${E}
    nu = ${nu}
    K1 = 0
    K2 = '300*t*1e5'
  [../]
[]

# [ICs]
#   [./d]
#     type = BrittleDamageIC
#     variable = d
#     d0 = 1.0
#     l = ${l}
#     x1 = '-0.5 -0.5'
#     y1 = '0.016667 -0.016667'
#     z1 = '0 0'
#     x2 = '0 0'
#     y2 = '0.016667 -0.016667'
#     z2 = '0 0'
#   [../]
#   # [./d]
#   #   type = CohesiveDamageIC
#   #   variable = d
#   #   d0 = 1.0
#   #   l = ${l}
#   #   x1 = '-0.5'
#   #   y1 = '0.016667'
#   #   z1 = '0'
#   #   x2 = '0'
#   #   y2 = '0.016667'
#   #   z2 = '0'
#   # [../]
# []

[Materials]
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
    type = SmallStrainDegradedElasticPK2Stress_StrainSpectral
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
[]

[Postprocessors]
  [./crack_length]
    type = FractureSurfaceArea
    d = 'd'
  [../]
[]

[Executioner]
  type = FixedPointTransient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -sub_pc_type -ksp_max_it -ksp_gmres_restart -sub_pc_factor_levels -snes_type'
  petsc_options_value = 'asm      ilu          200         200                0                     vinewtonrsls'
  dt = 1e-5
  end_time = 3e-4

  nl_abs_tol = 1e-08
  nl_rel_tol = 1e-06

  automatic_scaling = true
  compute_scaling_once = false

  fp_max_its = 100
  fp_tol = 1e-06
  accept_on_max_fp_iteration = true
[]

[Outputs]
  print_linear_residuals = false
  [./csv]
    type = CSV
    delimiter = ' '
    file_base = 'force_displacement'
  [../]
  [./exodus]
    type = Exodus
    file_base = 'K_field_results_coarser'
  [../]
  [./console]
    type = Console
    outlier_variable_norms = false
  [../]
[]
