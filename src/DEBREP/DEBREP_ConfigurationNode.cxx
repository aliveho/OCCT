// Copyright (c) 2022 OPEN CASCADE SAS
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

#include <DEBREP_ConfigurationNode.hxx>

#include <DEBREP_Provider.hxx>
#include <DE_ConfigurationContext.hxx>
#include <DE_PluginHolder.hxx>
#include <NCollection_Buffer.hxx>

IMPLEMENT_STANDARD_RTTIEXT(DEBREP_ConfigurationNode, DE_ConfigurationNode)

namespace
{
static const TCollection_AsciiString& THE_CONFIGURATION_SCOPE()
{
  static const TCollection_AsciiString aScope = "provider";
  return aScope;
}

// Wrapper to auto-load DE component
DE_PluginHolder<DEBREP_ConfigurationNode> THE_OCCT_BREP_COMPONENT_PLUGIN;
} // namespace

//=================================================================================================

DEBREP_ConfigurationNode::DEBREP_ConfigurationNode()
    : DE_ConfigurationNode()
{
}

//=================================================================================================

DEBREP_ConfigurationNode::DEBREP_ConfigurationNode(const Handle(DEBREP_ConfigurationNode)& theNode)
    : DE_ConfigurationNode(theNode)
{
  InternalParameters = theNode->InternalParameters;
}

//=================================================================================================

bool DEBREP_ConfigurationNode::Load(const Handle(DE_ConfigurationContext)& theResource)
{
  TCollection_AsciiString aScope =
    THE_CONFIGURATION_SCOPE() + "." + GetFormat() + "." + GetVendor();

  InternalParameters.WriteBinary =
    theResource->BooleanVal("write.binary", InternalParameters.WriteBinary, aScope);
  InternalParameters.WriteVersionBin =
    (BinTools_FormatVersion)theResource->IntegerVal("write.version.binary",
                                                    InternalParameters.WriteVersionBin,
                                                    aScope);
  InternalParameters.WriteVersionAscii =
    (TopTools_FormatVersion)theResource->IntegerVal("write.version.ascii",
                                                    InternalParameters.WriteVersionAscii,
                                                    aScope);
  InternalParameters.WriteTriangles =
    theResource->BooleanVal("write.triangles", InternalParameters.WriteTriangles, aScope);
  InternalParameters.WriteNormals =
    theResource->BooleanVal("write.normals", InternalParameters.WriteNormals, aScope);
  return true;
}

//=================================================================================================

TCollection_AsciiString DEBREP_ConfigurationNode::Save() const
{
  TCollection_AsciiString aResult;
  aResult += "!*****************************************************************************\n";
  aResult =
    aResult + "!Configuration Node " + " Vendor: " + GetVendor() + " Format: " + GetFormat() + "\n";
  TCollection_AsciiString aScope =
    THE_CONFIGURATION_SCOPE() + "." + GetFormat() + "." + GetVendor() + ".";

  aResult += "!\n";
  aResult += "!Write parameters:\n";
  aResult += "!\n";

  aResult += "!\n";
  aResult += "!Defines the binary file format\n";
  aResult += "!Default value: 1. Available values: 0(\"off\"), 1(\"on\")\n";
  aResult += aScope + "write.binary :\t " + InternalParameters.WriteBinary + "\n";
  aResult += "!\n";

  aResult += "!\n";
  aResult += "!Defines the format version for the binary format writing\n";
  aResult += "!Default value: 4. Available values: 1, 2, 3, 4\n";
  aResult += aScope + "write.version.binary :\t " + InternalParameters.WriteVersionBin + "\n";
  aResult += "!\n";

  aResult += "!\n";
  aResult += "!Defines the format version for the ASCII format writing\n";
  aResult += "!Default value: 3. Available values: 1, 2, 3\n";
  aResult += aScope + "write.version.ascii :\t " + InternalParameters.WriteVersionAscii + "\n";
  aResult += "!\n";

  aResult += "!\n";
  aResult += "!Defines the flag for storing shape with(without) triangles\n";
  aResult += "!Default value: 1. Available values: 0(\"off\"), 1(\"on\")\n";
  aResult += aScope + "write.triangles :\t " + InternalParameters.WriteTriangles + "\n";
  aResult += "!\n";

  aResult += "!\n";
  aResult += "!Defines the flag for storing shape with(without) normals\n";
  aResult += "!Default value: 1. Available values: 0(\"off\"), 1(\"on\")\n";
  aResult += aScope + "write.normals :\t " + InternalParameters.WriteNormals + "\n";
  aResult += "!\n";

  aResult += "!*****************************************************************************\n";
  return aResult;
}

//=================================================================================================

Handle(DE_ConfigurationNode) DEBREP_ConfigurationNode::Copy() const
{
  return new DEBREP_ConfigurationNode(*this);
}

//=================================================================================================

Handle(DE_Provider) DEBREP_ConfigurationNode::BuildProvider()
{
  return new DEBREP_Provider(this);
}

//=================================================================================================

bool DEBREP_ConfigurationNode::IsImportSupported() const
{
  return true;
}

//=================================================================================================

bool DEBREP_ConfigurationNode::IsExportSupported() const
{
  return true;
}

//=================================================================================================

TCollection_AsciiString DEBREP_ConfigurationNode::GetFormat() const
{
  return TCollection_AsciiString("BREP");
}

//=================================================================================================

TCollection_AsciiString DEBREP_ConfigurationNode::GetVendor() const
{
  return TCollection_AsciiString("OCC");
}

//=================================================================================================

TColStd_ListOfAsciiString DEBREP_ConfigurationNode::GetExtensions() const
{
  TColStd_ListOfAsciiString anExt;
  anExt.Append("brep");
  return anExt;
}

//=================================================================================================

bool DEBREP_ConfigurationNode::CheckContent(const Handle(NCollection_Buffer)& theBuffer) const
{
  if (theBuffer.IsNull() || theBuffer->Size() < 20)
  {
    return false;
  }
  const char* aBytes = (const char*)theBuffer->Data();
  if (::strstr(aBytes, "DBRep_DrawableShape") || ::strstr(aBytes, "CASCADE Topology V1")
      || ::strstr(aBytes, "CASCADE Topology V3"))
  {
    return true;
  }
  return false;
}
