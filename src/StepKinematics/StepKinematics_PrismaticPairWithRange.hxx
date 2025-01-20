// Created on : Sat May 02 12:41:15 2020 
// Created by: Irina KRYLOVA
// Generator:	Express (EXPRESS -> CASCADE/XSTEP Translator) V3.0
// Copyright (c) Open CASCADE 2020
//
// This file is part of Open CASCADE Technology software library.
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License version 2.1 as published
// by the Free Software Foundation, with special exception defined in the file
// OCCT_LGPL_EXCEPTION.txt. Consult the file LICENSE_LGPL_21.txt included in OCCT
// distribution for complete text of the license and disclaimer of any warranty.
//
// Alternatively, this file may be used under the terms of Open CASCADE
// commercial license or contractual agreement.

#ifndef _StepKinematics_PrismaticPairWithRange_HeaderFile_
#define _StepKinematics_PrismaticPairWithRange_HeaderFile_

#include <Standard.hxx>
#include <StepKinematics_PrismaticPair.hxx>

#include <TCollection_HAsciiString.hxx>
#include <StepRepr_RepresentationItem.hxx>
#include <StepKinematics_KinematicJoint.hxx>

DEFINE_STANDARD_HANDLE(StepKinematics_PrismaticPairWithRange, StepKinematics_PrismaticPair)

//! Representation of STEP entity PrismaticPairWithRange
class StepKinematics_PrismaticPairWithRange : public StepKinematics_PrismaticPair
{
public :

  //! default constructor
  Standard_EXPORT StepKinematics_PrismaticPairWithRange();

  //! Initialize all fields (own and inherited)
 Standard_EXPORT void Init(const Handle(TCollection_HAsciiString)& theRepresentationItem_Name,
                           const Handle(TCollection_HAsciiString)& theItemDefinedTransformation_Name,
                           const Standard_Boolean hasItemDefinedTransformation_Description,
                           const Handle(TCollection_HAsciiString)& theItemDefinedTransformation_Description,
                           const Handle(StepRepr_RepresentationItem)& theItemDefinedTransformation_TransformItem1,
                           const Handle(StepRepr_RepresentationItem)& theItemDefinedTransformation_TransformItem2,
                           const Handle(StepKinematics_KinematicJoint)& theKinematicPair_Joint,
                           const Standard_Boolean theLowOrderKinematicPair_TX,
                           const Standard_Boolean theLowOrderKinematicPair_TY,
                           const Standard_Boolean theLowOrderKinematicPair_TZ,
                           const Standard_Boolean theLowOrderKinematicPair_RX,
                           const Standard_Boolean theLowOrderKinematicPair_RY,
                           const Standard_Boolean theLowOrderKinematicPair_RZ,
                           const Standard_Boolean hasLowerLimitActualTranslation,
                           const Standard_Real theLowerLimitActualTranslation,
                           const Standard_Boolean hasUpperLimitActualTranslation,
                           const Standard_Real theUpperLimitActualTranslation);

  //! Returns field LowerLimitActualTranslation
  Standard_EXPORT Standard_Real LowerLimitActualTranslation() const;
  //! Sets field LowerLimitActualTranslation
  Standard_EXPORT void SetLowerLimitActualTranslation (const Standard_Real theLowerLimitActualTranslation);
  //! Returns True if optional field LowerLimitActualTranslation is defined
  Standard_EXPORT Standard_Boolean HasLowerLimitActualTranslation() const;

  //! Returns field UpperLimitActualTranslation
  Standard_EXPORT Standard_Real UpperLimitActualTranslation() const;
  //! Sets field UpperLimitActualTranslation
  Standard_EXPORT void SetUpperLimitActualTranslation (const Standard_Real theUpperLimitActualTranslation);
  //! Returns True if optional field UpperLimitActualTranslation is defined
  Standard_EXPORT Standard_Boolean HasUpperLimitActualTranslation() const;

DEFINE_STANDARD_RTTIEXT(StepKinematics_PrismaticPairWithRange, StepKinematics_PrismaticPair)

private:
  Standard_Real myLowerLimitActualTranslation; //!< optional
  Standard_Real myUpperLimitActualTranslation; //!< optional
// clang-format off
  Standard_Boolean defLowerLimitActualTranslation; //!< flag "is LowerLimitActualTranslation defined"
  Standard_Boolean defUpperLimitActualTranslation; //!< flag "is UpperLimitActualTranslation defined"
// clang-format on

};
#endif // _StepKinematics_PrismaticPairWithRange_HeaderFile_
