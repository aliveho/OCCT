// Created on: 1999-11-26
// Created by: Andrey BETENEV
// Copyright (c) 1999 Matra Datavision
// Copyright (c) 1999-2014 OPEN CASCADE SAS
//
// This file is part of Open CASCADE Technology software library.
//
// This library is free software; you can redistribute it and / or modify it
// under the terms of the GNU Lesser General Public version 2.1 as published
// by the Free Software Foundation, with special exception defined in the file
// OCCT_LGPL_EXCEPTION.txt. Consult the file LICENSE_LGPL_21.txt included in OCCT
// distribution for complete text of the license and disclaimer of any warranty.
//
// Alternatively, this file may be used under the terms of Open CASCADE
// commercial license or contractual agreement.

// Generator:	ExpToCas (EXPRESS -> CASCADE/XSTEP Translator) V1.0

#include <StepAP203_ContractedItem.ixx>

//=======================================================================
//function : StepAP203_ContractedItem
//purpose  : 
//=======================================================================

StepAP203_ContractedItem::StepAP203_ContractedItem ()
{
}

//=======================================================================
//function : CaseNum
//purpose  : 
//=======================================================================

Standard_Integer StepAP203_ContractedItem::CaseNum (const Handle(Standard_Transient)& ent) const
{
  if (ent.IsNull()) return 0;
  if (ent->IsKind(STANDARD_TYPE(StepBasic_ProductDefinitionFormation))) return 1;
  return 0;
}

//=======================================================================
//function : ProductDefinitionFormation
//purpose  : 
//=======================================================================

Handle(StepBasic_ProductDefinitionFormation) StepAP203_ContractedItem::ProductDefinitionFormation () const
{
  return Handle(StepBasic_ProductDefinitionFormation)::DownCast(Value());
}
