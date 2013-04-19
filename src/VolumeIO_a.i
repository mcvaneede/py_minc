%module VolumeIO_a
%include typemaps.i
%{
#include <stdbool.h>
#include <volume_io.h>
#define MAX_DIM  5  
%}

%include carrays.i

%typemap(python,in) Volume volume {
  if (!PyCObject_Check($input)) { 
    PyErr_SetString(PyExc_TypeError, "Volume argument should be of type CObject");
    return NULL; 
  }
  $1 = (Volume) PyCObject_AsVoidPtr($input);
}

%typemap(python,out) Volume {
  if($1 == NULL) {   /* return NULL pointers as None */
    Py_INCREF(Py_None);
    $result = Py_None;
  }
  else {                  /* otherwise return CObject */
    $result = PyCObject_FromVoidPtr((void *) $1, NULL);
  }
}

/* create a MAX_DIM element array from a Python n-tuple */
%typemap(python,in) Real[MAX_DIM](double temp[MAX_DIM]) {
  /* temp[MAX_DIM] becomes a local variable */
  int i;
  for(i = 0; i < MAX_DIM; i++) {
    temp[i] = 0.0;  /* default values */
  }
  if (PyTuple_Check($input)) {
    if (!PyArg_ParseTuple($input, "d|dddd" ,temp,temp+1,temp+2,temp+3,temp+4)) {
      PyErr_SetString(PyExc_TypeError,"Expected a tuple of Real values");
      return NULL; 
    } 
    $1 = &temp[0];
  } else {
    PyErr_SetString(PyExc_TypeError,"expected a tuple");
    return NULL;
  }
}

/* create a MAX_DIM element array from a Python n-tuple */
%typemap(python,in) int[MAX_DIM](int temp[MAX_DIM]) {
  /* temp[MAX_DIM] becomes a local variable */
  int i;
  for(i = 0; i < MAX_DIM; i++) {
    temp[i] = 0;  /* default values */
  }
  if (PyTuple_Check($input)) {
    if (!PyArg_ParseTuple($input, "i|iiii" ,temp,temp+1,temp+2,temp+3,temp+4)) {
      PyErr_SetString(PyExc_TypeError,"Expected a tuple of integer values");
      return NULL; 
    } 
    $1 = &temp[0];
  } else {
    PyErr_SetString(PyExc_TypeError,"Expected a tuple");
    return NULL;
  }
}

/* create a MAX_DIM element array from a Python n-tuple */
%typemap(python,in) char *[MAX_DIM](char *temp[MAX_DIM]) {
  /* temp[MAX_DIM] becomes a local variable */
  int i;
  for(i = 0; i < MAX_DIM; i++) {
    temp[i] = NULL;  /* default values */
  }
  if (PyTuple_Check($input)) {
    if (!PyArg_ParseTuple($input, "s|ssss" ,
			  temp,temp+1,temp+2,temp+3,temp+4)) {
      PyErr_SetString(PyExc_TypeError,"Expected a tuple of string values");
      return NULL; 
    } 
    $1 = &temp[0];
  } else {
    PyErr_SetString(PyExc_TypeError,"Expected a tuple");
    return NULL;
  }
}


%apply double *OUTPUT { Real *voxel_min, Real *voxel_max, Real *max_value, 
	Real *min_value, Real *x_world, Real *y_world, Real *z_world,
	Real *voxel1,  Real *voxel2, Real *voxel3,
	Real *x_transformed, Real *y_transformed, Real *z_transformed};

%apply bool *OUTPUT { BOOLEAN *signed_flag };

typedef double Real;
typedef char * STRING;
typedef int   nc_type;
typedef bool BOOLEAN;
typedef void *Volume;
typedef int Cache_block_size_hints;
typedef int Status;

%array_functions(Real, RealArray)
%array_functions(int, intArray)


%inline %{  // allocation functions for General_transform type
  General_transform *new_General_transform(void) {
    return (General_transform *) malloc(sizeof(General_transform));
  }
  
  void free_General_transform(General_transform *transform) {
    free(transform);
  }
%}


Real  convert_voxel_to_value(
    Volume   volume,
    Real     voxel );

Real  convert_value_to_voxel(
    Volume   volume,
    Real     value );

Real  get_volume_voxel_value(
    Volume   volume,
    int      v0,
    int      v1 = 0,
    int      v2 = 0,
    int      v3 = 0,
    int      v4 = 0 );

Real  get_volume_real_value(
    Volume   volume,
    int      v0,
    int      v1 = 0,
    int      v2 = 0,
    int      v3 = 0,
    int      v4 = 0 );

void  set_volume_voxel_value(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      v4,
    Real     voxel );

void  set_volume_real_value(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      v4,
    Real     value );

void  set_voxel_to_world_transform(
    Volume             volume,
    General_transform  *transform );

General_transform  *get_voxel_to_world_transform(
    Volume   volume );

unsigned int  get_volume_total_n_voxels(
    Volume    volume );

int  get_volume_n_dimensions(
    Volume   volume );

STRING  get_volume_space_type(
    Volume   volume );

void  set_volume_space_type(
    Volume   volume,
    STRING   name );

Real  get_volume_voxel_min(
    Volume   volume );

Real  get_volume_voxel_max(
    Volume   volume );

void  set_volume_voxel_range(
    Volume   volume,
    Real     voxel_min,
    Real     voxel_max );

Real  get_volume_real_min(
    Volume     volume );

Real  get_volume_real_max(
    Volume     volume );

void  set_volume_real_range(
    Volume   volume,
    Real     real_min,
    Real     real_max );

void  set_volume_type(
    Volume       volume,
    nc_type      nc_data_type,
    BOOLEAN      signed_flag,
    Real         voxel_min,
    Real         voxel_max );

void  get_volume_sizes(
    Volume   volume,
    int      sizes[] );

void  set_volume_sizes(
    Volume       volume,
    int          sizes[MAX_DIM] );

void  get_volume_separations(
    Volume   volume,
    Real      separations[] );

void  set_volume_separations(
    Volume   volume,
    Real     separations[MAX_DIM] );

void  set_volume_starts(
    Volume  volume,
    Real    starts[MAX_DIM] );

void  get_volume_starts(
    Volume  volume,
    Real    starts[] );

void  set_volume_direction_unit_cosine(
    Volume   volume,
    int      axis,
    Real     dir[MAX_DIM] );

void  set_volume_direction_cosine(
    Volume   volume,
    int      axis,
    Real     dir[MAX_DIM] );

void  get_volume_direction_cosine(
    Volume   volume,
    int      axis,
    Real     dir[] );

void  set_volume_translation(
    Volume  volume,
    Real    voxel[MAX_DIM],
    Real    world_space_voxel_maps_to[MAX_DIM] );

void  get_volume_voxel_range(
    Volume     volume,
    Real       *voxel_min,
    Real       *voxel_max );

void  get_volume_real_range(
    Volume     volume,
    Real       *min_value,
    Real       *max_value );

void  set_n_bytes_cache_threshold(
    int  threshold );

int  get_n_bytes_cache_threshold( void );

Volume  copy_volume(
    Volume   volume );

void  set_volume_cache_size(
    Volume    volume,
    int       max_memory_bytes );

void  set_default_max_bytes_in_cache(
    int   max_bytes );

int  get_default_max_bytes_in_cache( void );


BOOLEAN  volume_is_cached(
    Volume  volume );

void  set_default_cache_block_sizes(
    int                      block_sizes[MAX_DIM] );

void  set_volume_cache_block_sizes(
    Volume    volume,
    int       block_sizes[MAX_DIM] );

void  set_cache_block_sizes_hint(
    Cache_block_size_hints  hint );

Volume   create_volume(
    int         n_dimensions,
    STRING      dimension_names[MAX_DIM],
    nc_type     nc_data_type,
    BOOLEAN     signed_flag,
    Real        voxel_min,
    Real        voxel_max );


void  alloc_volume_data(
    Volume   volume );

void  convert_voxel_to_world(
    Volume   volume,
    Real     voxel[MAX_DIM],
    Real     *x_world,
    Real     *y_world,
    Real     *z_world );

void  convert_world_to_voxel(
    Volume   volume,
    Real     x_world,
    Real     y_world,
    Real     z_world,
    Real     voxel[]  );

nc_type  get_volume_nc_data_type(
    Volume       volume,
    BOOLEAN      *signed_flag );

/*  ------------------------------------------ */
/*  Untested / disfunctional interfaces        */

void  set_volume_interpolation_tolerance(
    Real   tolerance );

int   evaluate_volume(
    Volume         volume,
    Real           voxel[],
    BOOLEAN        interpolating_dimensions[],
    int            degrees_continuity,
    BOOLEAN        use_linear_at_edge,
    Real           outside_value,
    Real           values[],
    Real           **first_deriv,
    Real           ***second_deriv );

void   evaluate_volume_in_world(
    Volume         volume,
    Real           x,
    Real           y,
    Real           z,
    int            degrees_continuity,
    BOOLEAN        use_linear_at_edge,
    Real           outside_value,
    Real           values[],
    Real           deriv_x[],
    Real           deriv_y[],
    Real           deriv_z[],
    Real           deriv_xx[],
    Real           deriv_xy[],
    Real           deriv_xz[],
    Real           deriv_yy[],
    Real           deriv_yz[],
    Real           deriv_zz[] );

void  convert_voxels_to_values(
    Volume   volume,
    int      n_voxels,
    Real     voxels[],
    Real     values[] );

void  get_volume_value_hyperslab(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      v4,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    int      n4,
    Real     values[] );

void  get_volume_value_hyperslab_5d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      v4,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    int      n4,
    Real     values[] );

void  get_volume_value_hyperslab_4d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    Real     values[] );

void  get_volume_value_hyperslab_3d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      n0,
    int      n1,
    int      n2,
    Real     values[] );

void  get_volume_value_hyperslab_2d(
    Volume   volume,
    int      v0,
    int      v1,
    int      n0,
    int      n1,
    Real     values[] );

void  get_volume_value_hyperslab_1d(
    Volume   volume,
    int      v0,
    int      n0,
    Real     values[] );

void  get_voxel_values_5d(
    Data_types  data_type,
    void        *void_ptr,
    int         steps[],
    int         counts[],
    Real        values[] );

void  get_voxel_values_4d(
    Data_types  data_type,
    void        *void_ptr,
    int         steps[],
    int         counts[],
    Real        values[] );

void  get_voxel_values_3d(
    Data_types  data_type,
    void        *void_ptr,
    int         steps[],
    int         counts[],
    Real        values[] );

void  get_voxel_values_2d(
    Data_types  data_type,
    void        *void_ptr,
    int         steps[],
    int         counts[],
    Real        values[] );

void  get_voxel_values_1d(
    Data_types  data_type,
    void        *void_ptr,
    int         step0,
    int         n0,
    Real        values[] );

void  get_volume_voxel_hyperslab_5d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      v4,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    int      n4,
    Real     values[] );

void  get_volume_voxel_hyperslab_4d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    Real     values[] );

void  get_volume_voxel_hyperslab_3d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      n0,
    int      n1,
    int      n2,
    Real     values[] );

void  get_volume_voxel_hyperslab_2d(
    Volume   volume,
    int      v0,
    int      v1,
    int      n0,
    int      n1,
    Real     values[] );

void  get_volume_voxel_hyperslab_1d(
    Volume   volume,
    int      v0,
    int      n0,
    Real     values[] );

void  get_volume_voxel_hyperslab(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      v4,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    int      n4,
    Real     voxels[] );

Status  initialize_free_format_input(
    STRING               filename,
    Volume               volume,
    volume_input_struct  *volume_input );

void  delete_free_format_input(
    volume_input_struct   *volume_input );

BOOLEAN  input_more_free_format_file(
    Volume                volume,
    volume_input_struct   *volume_input,
    Real                  *fraction_done );

int   get_minc_file_n_dimensions(
    STRING   filename );

Minc_file  initialize_minc_input_from_minc_id(
    int                  minc_id,
    Volume               volume,
    minc_input_options   *options );

Minc_file  initialize_minc_input(
    STRING               filename,
    Volume               volume,
    minc_input_options   *options );

int  get_n_input_volumes(
    Minc_file  file );

Status  close_minc_input(
    Minc_file   file );

Status  input_minc_hyperslab(
    Minc_file        file,
    Data_types       data_type,
    int              n_array_dims,
    int              array_sizes[],
    void             *array_data_ptr,
    int              to_array[],
    int              start[],
    int              count[] );

BOOLEAN  input_more_minc_file(
    Minc_file   file,
    Real        *fraction_done );

BOOLEAN  advance_input_volume(
    Minc_file   file );

void  reset_input_volume(
    Minc_file   file );

int  get_minc_file_id(
    Minc_file  file );

void  set_default_minc_input_options(
    minc_input_options  *options );

void  set_minc_input_promote_invalid_to_zero_flag(
    minc_input_options  *options,
    BOOLEAN             flag );

void  set_minc_input_promote_invalid_to_min_flag(
    minc_input_options  *options,
    BOOLEAN             flag );

void  set_minc_input_vector_to_scalar_flag(
    minc_input_options  *options,
    BOOLEAN             flag );

void  set_minc_input_vector_to_colour_flag(
    minc_input_options  *options,
    BOOLEAN             flag );

void  set_minc_input_colour_dimension_size(
    minc_input_options  *options,
    int                 size );

void  set_minc_input_colour_max_dimension_size(
    minc_input_options  *options,
    int                 size );

void  set_minc_input_colour_indices(
    minc_input_options  *options,
    int                 indices[4] );

Status  start_volume_input(
    STRING               filename,
    int                  n_dimensions,
    STRING               dim_names[],
    nc_type              volume_nc_data_type,
    BOOLEAN              volume_signed_flag,
    Real                 volume_voxel_min,
    Real                 volume_voxel_max,
    BOOLEAN              create_volume_flag,
    Volume               *volume,
    minc_input_options   *options,
    volume_input_struct  *input_info );

void  delete_volume_input(
    volume_input_struct   *input_info );

BOOLEAN  input_more_of_volume(
    Volume                volume,
    volume_input_struct   *input_info,
    Real                  *fraction_done );

void  cancel_volume_input(
    Volume                volume,
    volume_input_struct   *input_info );

Status  input_volume(
    STRING               filename,
    int                  n_dimensions,
    STRING               dim_names[],
    nc_type              volume_nc_data_type,
    BOOLEAN              volume_signed_flag,
    Real                 volume_voxel_min,
    Real                 volume_voxel_max,
    BOOLEAN              create_volume_flag,
    Volume               *volume,
    minc_input_options   *options );

Minc_file   get_volume_input_minc_file(
    volume_input_struct   *volume_input );

 void   create_empty_multidim_array(
    multidim_array  *array,
    int             n_dimensions,
    Data_types      data_type );

Data_types  get_multidim_data_type(
    multidim_array       *array );

void  set_multidim_data_type(
    multidim_array       *array,
    Data_types           data_type );

int  get_type_size(
    Data_types   type );

void  get_type_range(
    Data_types   type,
    Real         *min_value,
    Real         *max_value );

void  set_multidim_sizes(
    multidim_array   *array,
    int              sizes[] );

void  get_multidim_sizes(
    multidim_array   *array,
    int              sizes[] );

BOOLEAN  multidim_array_is_alloced(
    multidim_array   *array );

void  alloc_multidim_array(
    multidim_array   *array );

 void   create_multidim_array(
    multidim_array  *array,
    int             n_dimensions,
    int             sizes[],
    Data_types      data_type );

void  delete_multidim_array(
    multidim_array   *array );

int  get_multidim_n_dimensions(
    multidim_array   *array );

void  copy_multidim_data_reordered(
    int                 type_size,
    void                *void_dest_ptr,
    int                 n_dest_dims,
    int                 dest_sizes[],
    void                *void_src_ptr,
    int                 n_src_dims,
    int                 src_sizes[],
    int                 counts[],
    int                 to_dest_index[],
    BOOLEAN             use_src_order );

void  copy_multidim_reordered(
    multidim_array      *dest,
    int                 dest_ind[],
    multidim_array      *src,
    int                 src_ind[],
    int                 counts[],
    int                 to_dest_index[] );

Minc_file  initialize_minc_output(
    STRING                 filename,
    int                    n_dimensions,
    STRING                 dim_names[],
    int                    sizes[],
    nc_type                file_nc_data_type,
    BOOLEAN                file_signed_flag,
    Real                   file_voxel_min,
    Real                   file_voxel_max,
    General_transform      *voxel_to_world_transform,
    Volume                 volume_to_attach,
    minc_output_options    *options );

Status  copy_auxiliary_data_from_minc_file(
    Minc_file   file,
    STRING      filename,
    STRING      history_string );

Status  copy_auxiliary_data_from_open_minc_file(
    Minc_file   file,
    int         src_cdfid,
    STRING      history_string );

Status  add_minc_history(
    Minc_file   file,
    STRING      history_string );

Status  set_minc_output_random_order(
    Minc_file   file );

Status  output_minc_hyperslab(
    Minc_file           file,
    Data_types          data_type,
    int                 n_array_dims,
    int                 array_sizes[],
    void                *array_data_ptr,
    int                 to_array[],
    int                 file_start[],
    int                 file_count[] );

Status  output_volume_to_minc_file_position(
    Minc_file   file,
    Volume      volume,
    int         volume_count[],
    long        file_start[] );

Status  output_minc_volume(
    Minc_file   file );

Status  close_minc_output(
    Minc_file   file );

void  set_default_minc_output_options(
    minc_output_options  *options           );

void  copy_minc_output_options(
    minc_output_options  *src,
    minc_output_options  *dest );

void  delete_minc_output_options(
    minc_output_options  *options           );

void  set_minc_output_dimensions_order(
    minc_output_options  *options,
    int                  n_dimensions,
    STRING               dimension_names[] );

void  set_minc_output_real_range(
    minc_output_options  *options,
    Real                 real_min,
    Real                 real_max );

void  set_minc_output_use_volume_starts_and_steps_flag(
    minc_output_options  *options,
    BOOLEAN              flag );

Status   get_file_dimension_names(
    STRING   filename,
    int      *n_dims,
    STRING   *dim_names[] );

STRING  *create_output_dim_names(
    Volume                volume,
    STRING                original_filename,
    minc_output_options   *options,
    int                   file_sizes[] );

Status   copy_volume_auxiliary_and_history(
    Minc_file   minc_file,
    STRING      filename,
    STRING      original_filename,
    STRING      history );

Status  output_modified_volume(
    STRING                filename,
    nc_type               file_nc_data_type,
    BOOLEAN               file_signed_flag,
    Real                  file_voxel_min,
    Real                  file_voxel_max,
    Volume                volume,
    STRING                original_filename,
    STRING                history,
    minc_output_options   *options );

Status  output_volume(
    STRING                filename,
    nc_type               file_nc_data_type,
    BOOLEAN               file_signed_flag,
    Real                  file_voxel_min,
    Real                  file_voxel_max,
    Volume                volume,
    STRING                history,
    minc_output_options   *options );

void  convert_values_to_voxels(
    Volume   volume,
    int      n_voxels,
    Real     values[],
    Real     voxels[] );

void  set_volume_value_hyperslab(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      v4,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    int      n4,
    Real     values[] );

void  set_volume_value_hyperslab_5d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      v4,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    int      n4,
    Real     values[] );

void  set_volume_value_hyperslab_4d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    Real     values[] );

void  set_volume_value_hyperslab_3d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      n0,
    int      n1,
    int      n2,
    Real     values[] );

void  set_volume_value_hyperslab_2d(
    Volume   volume,
    int      v0,
    int      v1,
    int      n0,
    int      n1,
    Real     values[] );

void  set_volume_value_hyperslab_1d(
    Volume   volume,
    int      v0,
    int      n0,
    Real     values[] );

void  set_volume_voxel_hyperslab_5d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      v4,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    int      n4,
    Real     values[] );

void  set_volume_voxel_hyperslab_4d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    Real     values[] );

void  set_volume_voxel_hyperslab_3d(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      n0,
    int      n1,
    int      n2,
    Real     values[] );

void  set_volume_voxel_hyperslab_2d(
    Volume   volume,
    int      v0,
    int      v1,
    int      n0,
    int      n1,
    Real     values[] );

void  set_volume_voxel_hyperslab_1d(
    Volume   volume,
    int      v0,
    int      n0,
    Real     values[] );

void  set_volume_voxel_hyperslab(
    Volume   volume,
    int      v0,
    int      v1,
    int      v2,
    int      v3,
    int      v4,
    int      n0,
    int      n1,
    int      n2,
    int      n3,
    int      n4,
    Real     voxels[] );

void  initialize_volume_cache(
    volume_cache_struct   *cache,
    Volume                volume );

BOOLEAN  volume_cache_is_alloced(
    volume_cache_struct   *cache );

void  flush_volume_cache(
    Volume                volume );

void  delete_volume_cache(
    volume_cache_struct   *cache,
    Volume                volume );

void  set_cache_output_volume_parameters(
    Volume                      volume,
    STRING                      filename,
    nc_type                     file_nc_data_type,
    BOOLEAN                     file_signed_flag,
    Real                        file_voxel_min,
    Real                        file_voxel_max,
    STRING                      original_filename,
    STRING                      history,
    minc_output_options         *options )
;

void  open_cache_volume_input_file(
    volume_cache_struct   *cache,
    Volume                volume,
    STRING                filename,
    minc_input_options    *options );

void  cache_volume_range_has_changed(
    Volume   volume );

void  set_cache_volume_file_offset(
    volume_cache_struct   *cache,
    Volume                volume,
    long                  file_offset[] );

Real  get_cached_volume_voxel(
    Volume   volume,
    int      x,
    int      y,
    int      z,
    int      t,
    int      v );

void  set_cached_volume_voxel(
    Volume   volume,
    int      x,
    int      y,
    int      z,
    int      t,
    int      v,
    Real     value );

BOOLEAN  cached_volume_has_been_modified(
    volume_cache_struct  *cache );

void   set_volume_cache_debugging(
    Volume   volume,
    int      output_every );

STRING  *get_default_dim_names(
    int    n_dimensions );

BOOLEAN  convert_dim_name_to_spatial_axis(
    STRING  name,
    int     *axis );

Data_types  get_volume_data_type(
    Volume       volume );

void  set_rgb_volume_flag(
    Volume   volume,
    BOOLEAN  flag );

BOOLEAN  is_an_rgb_volume(
    Volume   volume );

BOOLEAN  volume_is_alloced(
    Volume   volume );

void  free_volume_data(
    Volume   volume );

void  delete_volume(
    Volume   volume );

void  compute_world_transform(
    int                 spatial_axes[N_DIMENSIONS],
    Real                separations[],
    Real                direction_cosines[][N_DIMENSIONS],
    Real                starts[],
    General_transform   *world_transform );

void  convert_transform_to_starts_and_steps(
    General_transform  *transform,
    int                n_volume_dimensions,
    Real               step_signs[],
    int                spatial_axes[],
    Real               starts[],
    Real               steps[],
    Real               dir_cosines[][N_DIMENSIONS] );

STRING  *get_volume_dimension_names(
    Volume   volume );

void  delete_dimension_names(
    Volume   volume,
    STRING   dimension_names[] );

void  reorder_voxel_to_xyz(
    Volume   volume,
    Real     voxel[],
    Real     xyz[] );

void  reorder_xyz_to_voxel(
    Volume   volume,
    Real     xyz[],
    Real      voxel[] );

void  convert_3D_voxel_to_world(
    Volume   volume,
    Real     voxel1,
    Real     voxel2,
    Real     voxel3,
    Real     *x_world,
    Real     *y_world,
    Real     *z_world );

void  convert_voxel_normal_vector_to_world(
    Volume          volume,
    Real            voxel_vector[],
    Real            *x_world,
    Real            *y_world,
    Real            *z_world );

void  convert_voxel_vector_to_world(
    Volume          volume,
    Real            voxel_vector[],
    Real            *x_world,
    Real            *y_world,
    Real            *z_world );

void  convert_world_vector_to_voxel(
    Volume          volume,
    Real            x_world,
    Real            y_world,
    Real            z_world,
    Real            voxel_vector[]  );

void  convert_3D_world_to_voxel(
    Volume   volume,
    Real     x_world,
    Real     y_world,
    Real     z_world,
    Real     *voxel1,
    Real     *voxel2,
    Real     *voxel3 );

Volume   copy_volume_definition_no_alloc(
    Volume   volume,
    nc_type  nc_data_type,
    BOOLEAN  signed_flag,
    Real     voxel_min,
    Real     voxel_max );

Volume   copy_volume_definition(
    Volume   volume,
    nc_type  nc_data_type,
    BOOLEAN  signed_flag,
    Real     voxel_min,
    Real     voxel_max );

void  grid_transform_point(
    General_transform   *transform,
    Real                x,
    Real                y,
    Real                z,
    Real                *x_transformed,
    Real                *y_transformed,
    Real                *z_transformed );

void  grid_inverse_transform_point(
    General_transform   *transform,
    Real                x,
    Real                y,
    Real                z,
    Real                *x_transformed,
    Real                *y_transformed,
    Real                *z_transformed );

Status  mni_get_nonwhite_character(
    FILE   *file,
    char   *ch );

Status  mni_skip_expected_character(
    FILE   *file,
    char   expected_ch );

Status  mni_input_line(
    FILE     *file,
    STRING   *string );

Status  mni_input_string(
    FILE     *file,
    STRING   *string,
    char     termination_char1,
    char     termination_char2 );

Status  mni_input_keyword_and_equal_sign(
    FILE         *file,
    const char   keyword[],
    BOOLEAN      print_error_message );

Status  mni_input_real(
    FILE    *file,
    Real    *d );

Status  mni_input_reals(
    FILE    *file,
    int     *n,
    Real    *reals[] );

Status  mni_input_int(
    FILE    *file,
    int     *i );

void  output_comments(
    FILE     *file,
    STRING   comments );

STRING  get_default_tag_file_suffix( void );

Status  initialize_tag_file_output(
    FILE      *file,
    STRING    comments,
    int       n_volumes );

Status  output_one_tag(
    FILE      *file,
    int       n_volumes,
    Real      tag_volume1[],
    Real      tag_volume2[],
    Real      *weight,
    int       *structure_id,
    int       *patient_id,
    STRING    label );

void  terminate_tag_file_output(
    FILE    *file );

Status  output_tag_points(
    FILE      *file,
    STRING    comments,
    int       n_volumes,
    int       n_tag_points,
    Real      **tags_volume1,
    Real      **tags_volume2,
    Real      weights[],
    int       structure_ids[],
    int       patient_ids[],
    STRING    *labels );

void  free_tag_points(
    int       n_volumes,
    int       n_tag_points,
    Real      **tags_volume1,
    Real      **tags_volume2,
    Real      weights[],
    int       structure_ids[],
    int       patient_ids[],
    char      **labels );

Status  initialize_tag_file_input(
    FILE      *file,
    int       *n_volumes_ptr );

Status  output_tag_file(
    STRING    filename,
    STRING    comments,
    int       n_volumes,
    int       n_tag_points,
    Real      **tags_volume1,
    Real      **tags_volume2,
    Real      weights[],
    int       structure_ids[],
    int       patient_ids[],
    STRING    labels[] );

Status  input_tag_file(
    STRING    filename,
    int       *n_volumes,
    int       *n_tag_points,
    Real      ***tags_volume1,
    Real      ***tags_volume2,
    Real      **weights,
    int       **structure_ids,
    int       **patient_ids,
    STRING    *labels[] );

BOOLEAN  input_one_tag(
    FILE      *file,
    int       n_volumes,
    Real      tag_volume1[],
    Real      tag_volume2[],
    Real      *weight,
    int       *structure_id,
    int       *patient_id,
    STRING    *label,
    Status    *status );

Status  input_tag_points(
    FILE      *file,
    int       *n_volumes_ptr,
    int       *n_tag_points,
    Real      ***tags_volume1,
    Real      ***tags_volume2,
    Real      **weights,
    int       **structure_ids,
    int       **patient_ids,
    STRING    *labels[] );

void  evaluate_thin_plate_spline(
    int     n_dims,
    int     n_values,
    int     n_points,
    Real    **points,
    Real    **weights,
    Real    pos[],
    Real    values[],
    Real    **derivs );

void  thin_plate_spline_transform(
    int     n_dims,
    int     n_points,
    Real    **points,
    Real    **weights,
    Real    x,
    Real    y,
    Real    z,
    Real    *x_transformed,
    Real    *y_transformed,
    Real    *z_transformed );

void  thin_plate_spline_inverse_transform(
    int     n_dims,
    int     n_points,
    Real    **points,
    Real    **weights,
    Real    x,
    Real    y,
    Real    z,
    Real    *x_transformed,
    Real    *y_transformed,
    Real    *z_transformed );

Real  thin_plate_spline_U(
    Real   pos[],
    Real   landmark[],
    int    n_dims );

STRING  get_default_transform_file_suffix( void );

Status  output_transform(
    FILE                *file,
    STRING              filename,
    int                 *volume_count_ptr,
    STRING              comments,
    General_transform   *transform );

Status  input_transform(
    FILE                *file,
    STRING              filename,
    General_transform   *transform );

Status  output_transform_file(
    STRING              filename,
    STRING              comments,
    General_transform   *transform );

Status  input_transform_file(
    STRING              filename,
    General_transform   *transform );

void  create_linear_transform(
    General_transform   *transform,
    Transform           *linear_transform );

void  create_thin_plate_transform_real(
    General_transform    *transform,
    int                  n_dimensions,
    int                  n_points,
    Real                 **points,
    Real                 **displacements );

void  create_thin_plate_transform(
    General_transform    *transform,
    int                  n_dimensions,
    int                  n_points,
    float                **points,
    float                **displacements );

void  create_grid_transform(
    General_transform    *transform,
    Volume               displacement_volume );

void  create_grid_transform_no_copy(
    General_transform    *transform,
    Volume               displacement_volume );

void  create_user_transform(
    General_transform         *transform,
    void                      *user_data,
    size_t                    size_user_data,
    User_transform_function   transform_function,
    User_transform_function   inverse_transform_function );

Transform_types  get_transform_type(
    General_transform   *transform );

int  get_n_concated_transforms(
    General_transform   *transform );

General_transform  *get_nth_general_transform(
    General_transform   *transform,
    int                 n );

Transform  *get_linear_transform_ptr(
    General_transform   *transform );

Transform  *get_inverse_linear_transform_ptr(
    General_transform   *transform );

void  general_transform_point(
    General_transform   *transform,
    Real                x,
    Real                y,
    Real                z,
    Real                *x_transformed,
    Real                *y_transformed,
    Real                *z_transformed );

void  general_inverse_transform_point(
    General_transform   *transform,
    Real                x,
    Real                y,
    Real                z,
    Real                *x_transformed,
    Real                *y_transformed,
    Real                *z_transformed );

void  copy_general_transform(
    General_transform   *transform,
    General_transform   *copy );

void  invert_general_transform(
    General_transform   *transform );

void  create_inverse_general_transform(
    General_transform   *transform,
    General_transform   *inverse );

void  concat_general_transforms(
    General_transform   *first,
    General_transform   *second,
    General_transform   *result );

void  delete_general_transform(
    General_transform   *transform );

Colour  make_rgba_Colour(
    int    r,
    int    g,
    int    b,
    int    a );

int  get_Colour_r(
    Colour   colour );

int  get_Colour_g(
    Colour   colour );

int  get_Colour_b(
    Colour   colour );

int  get_Colour_a(
    Colour   colour );

Colour  make_Colour(
    int   r,
    int   g,
    int   b );

Real  get_Colour_r_0_1(
    Colour   colour );

Real  get_Colour_g_0_1(
    Colour   colour );

Real  get_Colour_b_0_1(
    Colour   colour );

Real  get_Colour_a_0_1(
    Colour   colour );

Colour  make_Colour_0_1(
    Real   r,
    Real   g,
    Real   b );

Colour  make_rgba_Colour_0_1(
    Real   r,
    Real   g,
    Real   b,
    Real   a );

BOOLEAN  scaled_maximal_pivoting_gaussian_elimination(
    int   n,
    int   row[],
    Real  **a,
    int   n_values,
    Real  **solution );

BOOLEAN  solve_linear_system(
    int   n,
    Real  **coefs,
    Real  values[],
    Real  solution[] );

BOOLEAN  invert_square_matrix(
    int   n,
    Real  **matrix,
    Real  **inverse );

/* BOOLEAN  newton_root_find(
    int    n_dimensions,
    void   (*function) ( void *, Real [],  Real [], Real ** ),
    void   *function_data,
    Real   initial_guess[],
    Real   desired_values[],
    Real   solution[],
    Real   function_tolerance,
    Real   delta_tolerance,
    int    max_iterations );
*/

void  create_orthogonal_vector(
    Vector  *v,
    Vector  *ortho );

void  create_two_orthogonal_vectors(
    Vector   *v,
    Vector   *v1,
    Vector   *v2 );

BOOLEAN   compute_transform_inverse(
    Transform  *transform,
    Transform  *inverse );

void  get_linear_spline_coefs(
    Real  **coefs );

void  get_quadratic_spline_coefs(
    Real  **coefs );

void  get_cubic_spline_coefs(
    Real  **coefs );

Real  cubic_interpolate(
    Real   u,
    Real   v0,
    Real   v1,
    Real   v2,
    Real   v3 );

void  evaluate_univariate_interpolating_spline(
    Real    u,
    int     degree,
    Real    coefs[],
    int     n_derivs,
    Real    derivs[] );

void  evaluate_bivariate_interpolating_spline(
    Real    u,
    Real    v,
    int     degree,
    Real    coefs[],
    int     n_derivs,
    Real    derivs[] );

void  evaluate_trivariate_interpolating_spline(
    Real    u,
    Real    v,
    Real    w,
    int     degree,
    Real    coefs[],
    int     n_derivs,
    Real    derivs[] );

void  evaluate_interpolating_spline(
    int     n_dims,
    Real    parameters[],
    int     degree,
    int     n_values,
    Real    coefs[],
    int     n_derivs,
    Real    derivs[] );

void  spline_tensor_product(
    int     n_dims,
    Real    positions[],
    int     degrees[],
    Real    *bases[],
    int     n_values,
    Real    coefs[],
    int     n_derivs[],
    Real    results[] );

void  make_identity_transform( Transform   *transform );

BOOLEAN  close_to_identity(
    Transform   *transform );

void  get_transform_origin(
    Transform   *transform,
    Point       *origin );

void  set_transform_origin(
    Transform   *transform,
    Point       *origin );

void  get_transform_origin_real(
    Transform   *transform,
    Real        origin[] );

void  get_transform_x_axis(
    Transform   *transform,
    Vector      *x_axis );

void  get_transform_x_axis_real(
    Transform   *transform,
    Real        x_axis[] );

void  set_transform_x_axis(
    Transform   *transform,
    Vector      *x_axis );

void  set_transform_x_axis_real(
    Transform   *transform,
    Real        x_axis[] );

void  get_transform_y_axis(
    Transform   *transform,
    Vector      *y_axis );

void  get_transform_y_axis_real(
    Transform   *transform,
    Real        y_axis[] );

void  set_transform_y_axis(
    Transform   *transform,
    Vector      *y_axis );

void  set_transform_y_axis_real(
    Transform   *transform,
    Real        y_axis[] );

void  get_transform_z_axis(
    Transform   *transform,
    Vector      *z_axis );

void  get_transform_z_axis_real(
    Transform   *transform,
    Real        z_axis[] );

void  set_transform_z_axis(
    Transform   *transform,
    Vector      *z_axis );

void  set_transform_z_axis_real(
    Transform   *transform,
    Real        z_axis[] );

void   make_change_to_bases_transform(
    Point      *origin,
    Vector     *x_axis,
    Vector     *y_axis,
    Vector     *z_axis,
    Transform  *transform );

void   make_change_from_bases_transform(
    Point      *origin,
    Vector     *x_axis,
    Vector     *y_axis,
    Vector     *z_axis,
    Transform  *transform );

void   concat_transforms(
    Transform   *result,
    Transform   *t1,
    Transform   *t2 );

void  transform_point(
    Transform  *transform,
    Real       x,
    Real       y,
    Real       z,
    Real       *x_trans,
    Real       *y_trans,
    Real       *z_trans );

void  transform_vector(
    Transform  *transform,
    Real       x,
    Real       y,
    Real       z,
    Real       *x_trans,
    Real       *y_trans,
    Real       *z_trans );

/*
void  *alloc_memory_in_bytes(
    size_t       n_bytes
    _ALLOC_SOURCE_LINE_ARG_DEF );

void  *alloc_memory_1d(
    size_t       n_elements,
    size_t       type_size
    _ALLOC_SOURCE_LINE_ARG_DEF );

void  *alloc_memory_2d(
    size_t       n1,
    size_t       n2,
    size_t       type_size
    _ALLOC_SOURCE_LINE_ARG_DEF );

void  *alloc_memory_3d(
    size_t       n1,
    size_t       n2,
    size_t       n3,
    size_t       type_size
    _ALLOC_SOURCE_LINE_ARG_DEF );

void  *alloc_memory_4d(
    size_t       n1,
    size_t       n2,
    size_t       n3,
    size_t       n4,
    size_t       type_size
    _ALLOC_SOURCE_LINE_ARG_DEF );

void  *alloc_memory_5d(
    size_t       n1,
    size_t       n2,
    size_t       n3,
    size_t       n4,
    size_t       n5,
    size_t       type_size
    _ALLOC_SOURCE_LINE_ARG_DEF );

void  realloc_memory(
    void      **ptr,
    size_t    n_elements,
    size_t    type_size
    _ALLOC_SOURCE_LINE_ARG_DEF );

void  free_memory_1d(
    void   **ptr
    _ALLOC_SOURCE_LINE_ARG_DEF );

void  free_memory_2d(
    void   ***ptr
    _ALLOC_SOURCE_LINE_ARG_DEF );

void  free_memory_3d(
    void   ****ptr
    _ALLOC_SOURCE_LINE_ARG_DEF );

void  free_memory_4d(
    void   *****ptr
    _ALLOC_SOURCE_LINE_ARG_DEF );

void  free_memory_5d(
    void   ******ptr
    _ALLOC_SOURCE_LINE_ARG_DEF );

size_t  get_total_memory_alloced( void );

BOOLEAN  alloc_checking_enabled( void );

void  set_alloc_checking( BOOLEAN state );

void  record_ptr_alloc_check(
    void      *ptr,
    size_t    n_bytes,
    STRING    source_file,
    int       line_number );

void  change_ptr_alloc_check(
    void      *old_ptr,
    void      *new_ptr,
    size_t    n_bytes,
    STRING    source_file,
    int       line_number );

BOOLEAN  unrecord_ptr_alloc_check(
    void     *ptr,
    STRING   source_file,
    int      line_number );

void  output_alloc_to_file(
    STRING   filename );

void  print_alloc_source_line(
    STRING  filename,
    int     line_number );

void  set_array_size(
    void      **array,
    size_t    type_size,
    size_t    previous_n_elems,
    size_t    new_n_elems,
    size_t    chunk_size
    _ALLOC_SOURCE_LINE_ARG_DEF );

BOOLEAN  real_is_double( void );
*/

BOOLEAN  file_exists(
    STRING        filename );

BOOLEAN  file_directory_exists(
    STRING        filename );

BOOLEAN  check_clobber_file(
    STRING   filename );

BOOLEAN  check_clobber_file_default_suffix(
    STRING   filename,
    STRING   default_suffix );

Status  make_backup_file(
    STRING   filename,
    STRING   *backup_filename );

void  cleanup_backup_file(
    STRING   filename,
    STRING   backup_filename,
    Status   status_of_write );

void  remove_file(
    STRING  filename );

Status  copy_file(
    STRING  src,
    STRING  dest );

Status  move_file(
    STRING  src,
    STRING  dest );

STRING  expand_filename(
    STRING  filename );

BOOLEAN  filename_extension_matches(
    STRING   filename,
    STRING   extension );

STRING  remove_directories_from_filename(
    STRING  filename );

BOOLEAN  file_exists_as_compressed(
    STRING       filename,
    STRING       *compressed_filename );

STRING  get_temporary_filename( void );

Status  open_file(
    STRING             filename,
    IO_types           io_type,
    File_formats       file_format,
    FILE               **file );

Status  open_file_with_default_suffix(
    STRING             filename,
    STRING             default_suffix,
    IO_types           io_type,
    File_formats       file_format,
    FILE               **file );

Status  set_file_position(
    FILE     *file,
    long     byte_position );

Status  close_file(
    FILE     *file );

STRING  extract_directory(
    STRING    filename );

STRING  get_absolute_filename(
    STRING    filename,
    STRING    directory );

Status  flush_file(
    FILE     *file );

Status  input_character(
    FILE  *file,
    char   *ch );

Status  unget_character(
    FILE  *file,
    char  ch );

Status  input_nonwhite_character(
    FILE   *file,
    char   *ch );

Status  output_character(
    FILE   *file,
    char   ch );

Status   skip_input_until(
    FILE   *file,
    char   search_char );

Status  output_string(
    FILE    *file,
    STRING  str );

Status  input_string(
    FILE    *file,
    STRING  *str,
    char    termination_char );

Status  input_quoted_string(
    FILE            *file,
    STRING          *str );

Status  input_possibly_quoted_string(
    FILE            *file,
    STRING          *str );

Status  output_quoted_string(
    FILE            *file,
    STRING          str );

Status  input_binary_data(
    FILE            *file,
    void            *data,
    size_t          element_size,
    int             n );

Status  output_binary_data(
    FILE            *file,
    void            *data,
    size_t          element_size,
    int             n );

Status  input_newline(
    FILE            *file );

Status  output_newline(
    FILE            *file );

Status  input_line(
    FILE    *file,
    STRING  *line );

Status  input_boolean(
    FILE            *file,
    BOOLEAN         *b );

Status  output_boolean(
    FILE            *file,
    BOOLEAN         b );

Status  input_short(
    FILE            *file,
    short           *s );

Status  output_short(
    FILE            *file,
    short           s );

Status  input_unsigned_short(
    FILE            *file,
    unsigned short  *s );

Status  output_unsigned_short(
    FILE            *file,
    unsigned short  s );

Status  input_int(
    FILE  *file,
    int   *i );

Status  output_int(
    FILE            *file,
    int             i );

Status  input_real(
    FILE            *file,
    Real            *r );

Status  output_real(
    FILE            *file,
    Real            r );

Status  input_float(
    FILE            *file,
    float           *f );

Status  output_float(
    FILE            *file,
    float           f );

Status  input_double(
    FILE            *file,
    double          *d );

Status  output_double(
    FILE            *file,
    double          d );

Status  io_binary_data(
    FILE            *file,
    IO_types        io_flag,
    void            *data,
    size_t          element_size,
    int             n );

Status  io_newline(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format );

Status  io_quoted_string(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format,
    STRING          *str );

Status  io_boolean(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format,
    BOOLEAN         *b );

Status  io_short(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format,
    short           *short_int );

Status  io_unsigned_short(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format,
    unsigned short  *unsigned_short );

Status  io_unsigned_char(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format,
    unsigned  char  *c );

Status  io_int(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format,
    int             *i );

Status  io_real(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format,
    Real            *r );

Status  io_float(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format,
    float           *f );

Status  io_double(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format,
    double          *d );

Status  io_ints(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format,
    int             n,
    int             *ints[] );

Status  io_unsigned_chars(
    FILE            *file,
    IO_types        io_flag,
    File_formats    format,
    int             n,
    unsigned char   *unsigned_chars[] );
/*
void  set_print_function( void  (*function) ( STRING ) );

void  push_print_function( void );

void  pop_print_function( void );

void  print( STRING format, ... );

void  set_print_error_function( void  (*function) ( char [] ) );

void  push_print_error_function( void );

void  pop_print_error_function( void );

void  print_error( char format[], ... );

void   handle_internal_error( char  str[] );

void  abort_if_allowed( void );
*/
void  initialize_progress_report(
    progress_struct   *progress,
    BOOLEAN           one_line_only,
    int               n_steps,
    STRING            title );

void  update_progress_report(
    progress_struct   *progress,
    int               current_step );

void  terminate_progress_report(
    progress_struct   *progress );

STRING  alloc_string(
    int   length );

STRING  create_string(
    STRING    initial );

void  delete_string(
    STRING   string );

STRING  concat_strings(
    STRING   str1,
    STRING   str2 );

void  replace_string(
    STRING   *string,
    STRING   new_string );

void  concat_char_to_string(
    STRING   *string,
    char     ch );

void  concat_to_string(
    STRING   *string,
    STRING   str2 );

int  string_length(
    STRING   string );

BOOLEAN  equal_strings(
    STRING   str1,
    STRING   str2 );

BOOLEAN  is_lower_case(
    char  ch );

BOOLEAN  is_upper_case(
    char  ch );

char  get_lower_case(
    char   ch );

char  get_upper_case(
    char   ch );

BOOLEAN  string_ends_in(
    STRING   string,
    STRING   ending );

  STRING   strip_outer_blanks(
    STRING  str );

int  find_character(
    STRING    string,
    char      ch );

void  make_string_upper_case(
    STRING    string );

BOOLEAN  blank_string(
    STRING   string );

Real  current_cpu_seconds( void );

Real  current_realtime_seconds( void );

STRING  format_time(
    STRING   format,
    Real     seconds );

void  print_time(
    STRING   format,
    Real     seconds );

STRING  get_clock_time( void );

void  sleep_program( Real seconds );

STRING  get_date( void );
