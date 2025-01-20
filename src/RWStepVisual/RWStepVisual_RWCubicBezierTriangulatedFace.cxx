// Created on : Thu Mar 24 18:30:11 2022 
// Created by: snn
// Generator: Express (EXPRESS -> CASCADE/XSTEP Translator) V2.0
// Copyright (c) Open CASCADE 2022
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

#include "RWStepVisual_RWCubicBezierTriangulatedFace.pxx"
#include <StepVisual_CubicBezierTriangulatedFace.hxx>
#include <Interface_EntityIterator.hxx>
#include <StepData_StepReaderData.hxx>
#include <StepData_StepWriter.hxx>
#include <TCollection_HAsciiString.hxx>
#include <StepVisual_CoordinatesList.hxx>
#include <Standard_Integer.hxx>
#include <TColStd_HArray2OfReal.hxx>
#include <TColStd_HArray1OfReal.hxx>
#include <Standard_Real.hxx>
#include <StepVisual_FaceOrSurface.hxx>
#include <TColStd_HArray2OfInteger.hxx>
#include <TColStd_HArray1OfInteger.hxx>

//=======================================================================
//function : RWStepVisual_RWCubicBezierTriangulatedFace
//purpose  : 
//=======================================================================

RWStepVisual_RWCubicBezierTriangulatedFace::RWStepVisual_RWCubicBezierTriangulatedFace() {}


//=======================================================================
//function : ReadStep
//purpose  : 
//=======================================================================

void RWStepVisual_RWCubicBezierTriangulatedFace::ReadStep(
  const Handle(StepData_StepReaderData)& theData,
  const Standard_Integer theNum,
  Handle(Interface_Check)& theCheck,
  const Handle(StepVisual_CubicBezierTriangulatedFace)& theEnt) const
{
  // Check number of parameters
  if (!theData->CheckNbParams(theNum, 6, theCheck, "cubic_bezier_triangulated_face"))
  {
    return;
  }

  // Inherited fields of RepresentationItem

  Handle(TCollection_HAsciiString) aRepresentationItem_Name;
  theData->ReadString(theNum, 1, "representation_item.name", theCheck, aRepresentationItem_Name);

  // Inherited fields of TessellatedFace

  Handle(StepVisual_CoordinatesList) aTessellatedFace_Coordinates;
  theData->ReadEntity(theNum, 2, "tessellated_face.coordinates", theCheck,
    STANDARD_TYPE(StepVisual_CoordinatesList), aTessellatedFace_Coordinates);

  Standard_Integer aTessellatedFace_Pnmax;
  theData->ReadInteger(theNum, 3, "tessellated_face.pnmax", theCheck, aTessellatedFace_Pnmax);

  Handle(TColStd_HArray2OfReal) aTessellatedFace_Normals;
  Standard_Integer sub4 = 0;
  if (theData->ReadSubList(theNum, 4, "tessellated_face.normals", theCheck, sub4))
  {
    Standard_Integer nb0 = theData->NbParams(sub4);
    Standard_Integer nbj0 = theData->NbParams(theData->ParamNumber(sub4,1));
    aTessellatedFace_Normals = new TColStd_HArray2OfReal(1, nb0, 1, nbj0);
    for (Standard_Integer i0 = 1; i0 <= nb0; i0++)
    {
      Standard_Integer subj4 = 0;
      if ( theData->ReadSubList (sub4, i0, "sub-part(tessellated_face.normals)", theCheck, subj4) ) {
        Standard_Integer num4 = subj4;
        for (Standard_Integer j0 = 1; j0 <= nbj0; j0++)
        {
          Standard_Real anIt0;
          theData->ReadReal(num4, j0, "real", theCheck, anIt0);
          aTessellatedFace_Normals->SetValue(i0,j0, anIt0);
        }
      }
    }
  }

  StepVisual_FaceOrSurface aTessellatedFace_GeometricLink;
  Standard_Boolean hasTessellatedFace_GeometricLink = Standard_True;
  if (theData->IsParamDefined(theNum, 5))
  {
    theData->ReadEntity(theNum, 5, "tessellated_face.geometric_link", theCheck, aTessellatedFace_GeometricLink);
  }
  else
  {
    hasTessellatedFace_GeometricLink = Standard_False;
    aTessellatedFace_GeometricLink = StepVisual_FaceOrSurface();
  }

  // Own fields of CubicBezierTriangulatedFace

  Handle(TColStd_HArray2OfInteger) aCtriangles;
  Standard_Integer sub6 = 0;
  if (theData->ReadSubList(theNum, 6, "ctriangles", theCheck, sub6))
  {
    Standard_Integer nb0 = theData->NbParams(sub6);
    Standard_Integer nbj0 = theData->NbParams(theData->ParamNumber(sub6,1));
    aCtriangles = new TColStd_HArray2OfInteger(1, nb0, 1, nbj0);
    for (Standard_Integer i0 = 1; i0 <= nb0; i0++)
    {
      Standard_Integer subj6 = 0;
      if ( theData->ReadSubList (sub6, i0, "sub-part(ctriangles)", theCheck, subj6) ) {
        Standard_Integer num4 = subj6;
        for (Standard_Integer j0 = 1; j0 <= nbj0; j0++)
        {
          Standard_Integer anIt0;
          theData->ReadInteger(num4, j0, "integer", theCheck, anIt0);
          aCtriangles->SetValue(i0,j0, anIt0);
        }
      }
    }
  }

  // Initialize entity
  theEnt->Init(aRepresentationItem_Name, aTessellatedFace_Coordinates, aTessellatedFace_Pnmax, aTessellatedFace_Normals, hasTessellatedFace_GeometricLink, aTessellatedFace_GeometricLink, aCtriangles);
}

//=======================================================================
//function : WriteStep
//purpose  : 
//=======================================================================

void RWStepVisual_RWCubicBezierTriangulatedFace::WriteStep(
  StepData_StepWriter& theSW,
  const Handle(StepVisual_CubicBezierTriangulatedFace)& theEnt) const
{

  // Own fields of RepresentationItem

  theSW.Send(theEnt->Name());

  // Own fields of TessellatedFace

  theSW.Send(theEnt->Coordinates());

  theSW.Send(theEnt->Pnmax());

  theSW.OpenSub();
  for (Standard_Integer i3 = 1; i3 <= theEnt->Normals()->RowLength(); i3++)
  {
    theSW.NewLine(Standard_False);
    theSW.OpenSub();
    for (Standard_Integer j3 = 1; j3 <= theEnt->Normals()->ColLength(); j3++)
    {
      Standard_Real Var0 = theEnt->Normals()->Value(i3,j3);
      theSW.Send(Var0);
    }
    theSW.CloseSub();
  }
  theSW.CloseSub();

  if (theEnt->HasGeometricLink())
  {
    theSW.Send(theEnt->GeometricLink().Value());
  }
  else
  {
    theSW.SendUndef();
  }

  // Own fields of CubicBezierTriangulatedFace

  theSW.OpenSub();
  for (Standard_Integer i5 = 1; i5 <= theEnt->Ctriangles()->RowLength(); i5++)
  {
    theSW.NewLine(Standard_False);
    theSW.OpenSub();
    for (Standard_Integer j5 = 1; j5 <= theEnt->Ctriangles()->ColLength(); j5++)
    {
      Standard_Integer Var0 = theEnt->Ctriangles()->Value(i5,j5);
      theSW.Send(Var0);
    }
    theSW.CloseSub();
  }
  theSW.CloseSub();
}

//=======================================================================
//function : Share
//purpose  : 
//=======================================================================

void RWStepVisual_RWCubicBezierTriangulatedFace::Share(
  const Handle(StepVisual_CubicBezierTriangulatedFace)&theEnt,
Interface_EntityIterator& theIter) const
{

  // Inherited fields of RepresentationItem

  // Inherited fields of TessellatedFace

  theIter.AddItem(theEnt->StepVisual_TessellatedFace::Coordinates());

  if (theEnt->StepVisual_TessellatedFace::HasGeometricLink())
  {
    theIter.AddItem(theEnt->StepVisual_TessellatedFace::GeometricLink().Value());
  }

  // Own fields of CubicBezierTriangulatedFace
}
