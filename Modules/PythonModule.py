import hou
from hou import lop
import lxml.etree as ET
import collections
import loputils
from pxr import Sdf


parser = ET.XMLParser(remove_blank_text=True)

UsdShaderTreeNodeName = 'UsdShaderTree'
rootNode = hou.OpNode
UsdShaderTreeNode = hou.OpNode
UsdLibraryTreeNode = hou.OpNode
materials = collections.OrderedDict()

def loadXmlFile(xmlFile):
    if (xmlFile != ""):
        xmlTree = ET.parse(xmlFile, parser)
        
        #----- Keep for future implementations
        # xmlDataRoot = xmlTree.getroot()
        # materialList = xmlDataRoot.findall(".//advancedMaterial")
        # for material in materialList:
        #     materials[material.get("id")] = material.get("name")
            
    return(xmlTree)
    
def loadXslFile(xslFile):
    if (xslFile != ""):
        xslTree = ET.parse(xslFile, parser)
    
    return xslTree
    
def buildMaterials(kwargs):
    node:hou.LopNode = kwargs['node']
    UsdShaderTreeNode = hou.pwd().node(UsdShaderTreeNodeName)

    xmlFile = hou.pwd().parm("XmlFileName").eval()
    xmlTree = loadXmlFile(xmlFile)
    xslFile = hou.pwd().parm("XsltFileName").eval()
    xslTree = loadXslFile(xslFile)
    
    xslTransform = ET.XSLT(xslTree)
    usdResult = xslTransform(xmlTree)
    print(hou.pwd().parm("printResult").eval())
    if hou.pwd().parm("printResult").eval() == 1:
        print("/" + str(usdResult))
    UsdShaderTreeNode.parm("usdsource").set(str(usdResult))
    
