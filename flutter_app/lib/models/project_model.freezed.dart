// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectModel {

 int? get id; String get name; String? get description; EProjectState get state; bool get isPublic; String? get startDate; String? get endDate; double? get budget; int? get estimatedHours; CustomerModel get customer; int? get customerId;
/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelCopyWith<ProjectModel> get copyWith => _$ProjectModelCopyWithImpl<ProjectModel>(this as ProjectModel, _$identity);

  /// Serializes this ProjectModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.state, state) || other.state == state)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.estimatedHours, estimatedHours) || other.estimatedHours == estimatedHours)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.customerId, customerId) || other.customerId == customerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,state,isPublic,startDate,endDate,budget,estimatedHours,customer,customerId);

@override
String toString() {
  return 'ProjectModel(id: $id, name: $name, description: $description, state: $state, isPublic: $isPublic, startDate: $startDate, endDate: $endDate, budget: $budget, estimatedHours: $estimatedHours, customer: $customer, customerId: $customerId)';
}


}

/// @nodoc
abstract mixin class $ProjectModelCopyWith<$Res>  {
  factory $ProjectModelCopyWith(ProjectModel value, $Res Function(ProjectModel) _then) = _$ProjectModelCopyWithImpl;
@useResult
$Res call({
 int? id, String name, String? description, EProjectState state, bool isPublic, String? startDate, String? endDate, double? budget, int? estimatedHours, CustomerModel customer, int? customerId
});


$CustomerModelCopyWith<$Res> get customer;

}
/// @nodoc
class _$ProjectModelCopyWithImpl<$Res>
    implements $ProjectModelCopyWith<$Res> {
  _$ProjectModelCopyWithImpl(this._self, this._then);

  final ProjectModel _self;
  final $Res Function(ProjectModel) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? description = freezed,Object? state = null,Object? isPublic = null,Object? startDate = freezed,Object? endDate = freezed,Object? budget = freezed,Object? estimatedHours = freezed,Object? customer = null,Object? customerId = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as EProjectState,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as double?,estimatedHours: freezed == estimatedHours ? _self.estimatedHours : estimatedHours // ignore: cast_nullable_to_non_nullable
as int?,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerModel,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerModelCopyWith<$Res> get customer {
  
  return $CustomerModelCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _ProjectModel implements ProjectModel {
  const _ProjectModel({this.id, required this.name, this.description, required this.state, required this.isPublic, this.startDate, this.endDate, this.budget, this.estimatedHours, required this.customer, this.customerId});
  factory _ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);

@override final  int? id;
@override final  String name;
@override final  String? description;
@override final  EProjectState state;
@override final  bool isPublic;
@override final  String? startDate;
@override final  String? endDate;
@override final  double? budget;
@override final  int? estimatedHours;
@override final  CustomerModel customer;
@override final  int? customerId;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectModelCopyWith<_ProjectModel> get copyWith => __$ProjectModelCopyWithImpl<_ProjectModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.state, state) || other.state == state)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.estimatedHours, estimatedHours) || other.estimatedHours == estimatedHours)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.customerId, customerId) || other.customerId == customerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,state,isPublic,startDate,endDate,budget,estimatedHours,customer,customerId);

@override
String toString() {
  return 'ProjectModel(id: $id, name: $name, description: $description, state: $state, isPublic: $isPublic, startDate: $startDate, endDate: $endDate, budget: $budget, estimatedHours: $estimatedHours, customer: $customer, customerId: $customerId)';
}


}

/// @nodoc
abstract mixin class _$ProjectModelCopyWith<$Res> implements $ProjectModelCopyWith<$Res> {
  factory _$ProjectModelCopyWith(_ProjectModel value, $Res Function(_ProjectModel) _then) = __$ProjectModelCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, String? description, EProjectState state, bool isPublic, String? startDate, String? endDate, double? budget, int? estimatedHours, CustomerModel customer, int? customerId
});


@override $CustomerModelCopyWith<$Res> get customer;

}
/// @nodoc
class __$ProjectModelCopyWithImpl<$Res>
    implements _$ProjectModelCopyWith<$Res> {
  __$ProjectModelCopyWithImpl(this._self, this._then);

  final _ProjectModel _self;
  final $Res Function(_ProjectModel) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? description = freezed,Object? state = null,Object? isPublic = null,Object? startDate = freezed,Object? endDate = freezed,Object? budget = freezed,Object? estimatedHours = freezed,Object? customer = null,Object? customerId = freezed,}) {
  return _then(_ProjectModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as EProjectState,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as double?,estimatedHours: freezed == estimatedHours ? _self.estimatedHours : estimatedHours // ignore: cast_nullable_to_non_nullable
as int?,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerModel,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerModelCopyWith<$Res> get customer {
  
  return $CustomerModelCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}

// dart format on
