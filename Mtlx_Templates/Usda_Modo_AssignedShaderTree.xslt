<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:array="http://www.w3.org/2005/xpath-functions/array"
				xmlns:map="http://www.w3.org/2005/xpath-functions/map"
				xmlns:math="http://www.w3.org/2005/xpath-functions/math"
				exclude-result-prefixes="#all"
				expand-text="no"
				version="3.0">

	<xsl:output method="text" indent="no" suppress-indentation="no" />
	<!--<xsl:mode on-no-match="shallow-copy"/>-->
<xsl:param name="geometry_path"/>

<xsl:template match="/">#usda 1.0
(
	endTimeCode = 1
	framesPerSecond = 24
	metersPerUnit = 1
	startTimeCode = 1
	timeCodesPerSecond = 24
	upAxis = "Y"
)


def Scope "modo"
{
	def Scope "shadertree"
	{
	<xsl:apply-templates select="polyRender/mask"/>
	<xsl:apply-templates select="polyRender/advancedMaterial"/>
	}
}

over "<xsl:choose>
    <xsl:when test="$geometry_path=''">modo</xsl:when>
    <xsl:when test="$geometry_path!=''"><xsl:value-of select="substring-after($geometry_path,'/')"/></xsl:when>
</xsl:choose>"
{
    over "Mesh"
    {
        over "Mesh_Shape_SubD"
        {
            uniform token subsetFamily:materialBind:familyType = "nonOverlapping"
            <xsl:for-each select="//mask">
                <xsl:call-template name="mask-assign"/>
            </xsl:for-each>
        }
    }
}
</xsl:template>

<xsl:template match="mask/channels" mode="#default"></xsl:template>

<xsl:template match="advancedMaterial"><xsl:call-template name="advancedMaterial"><xsl:with-param name="maskName"/></xsl:call-template></xsl:template>

<xsl:template match="mask/advancedMaterial"><xsl:call-template name="advancedMaterial"><xsl:with-param name="maskName" select="ancestor::mask[1]/@name"/></xsl:call-template></xsl:template>

<xsl:template name="mask-assign">
            over "material_<xsl:value-of select="channels/ptag/@value"/>" (
                prepend apiSchemas = ["MaterialBindingAPI"]
            )
            {
                uniform token familyName = "materialBind"
                rel material:binding = &lt;/modo/shadertree/<xsl:value-of select="@name"/>&gt;
            }
</xsl:template>


<xsl:template name="advancedMaterial">
	<xsl:param name="maskName"/>
	<xsl:variable name="materialName">
		<xsl:if test="$maskName != ''"><xsl:value-of select="$maskName"/></xsl:if>
		<xsl:if test="$maskName = ''"><xsl:value-of select="@name"/></xsl:if>
	</xsl:variable>
		def Material "<xsl:value-of select="$materialName"/>" (
			prepend inherits = &lt;/__class_mtl__<xsl:value-of select="$geometry_path"/>/shadertree/<xsl:value-of select="$materialName"/>&gt;
		)
		{
			token outputs:mtlx:displacement.connect = &lt;/modo/shadertree/<xsl:value-of select="$materialName"/>/mtlxdisplacement.outputs:out&gt;
			token outputs:mtlx:surface.connect = &lt;/modo/shadertree/<xsl:value-of select="$materialName"/>/mtlxstandard_surface.outputs:out&gt;
			token outputs:surface.connect = &lt;/modo/shadertree/<xsl:value-of select="$materialName"/>/mtlxstandard_preview.outputs:surface&gt;

			def Shader "mtlxstandard_surface"
			{
				uniform token info:id = "ND_standard_surface_surfaceshader"<xsl:apply-templates select="./channels"/>
				token outputs:out
			}

			def Shader "mtlxdisplacement"
			{
				uniform token info:id = "ND_displacement_float"
				token outputs:out
			}<!--
			def Shader "mtlxstandard_preview" (
				customData = {
					bool HoudiniIsAutoCreatedShader = 1
				}
			)
			{
				uniform token info:id = "UsdPreviewSurface"
				float inputs:clearcoatRoughness = 0.1
				color3f inputs:diffuseColor = (0, 0.5, 0)
				float inputs:roughness = 0.2
				color3f inputs:specularColor = (0, 0.5, 0.25)
				token outputs:surface
			}-->
		}
</xsl:template>

<xsl:template match="channels">
	<xsl:if test="./useRefIdx[@value='0']">
		<xsl:call-template name="write_input">
			<xsl:with-param name="new_name">specular_IOR</xsl:with-param>
			<xsl:with-param name="new_type">float</xsl:with-param>
			<xsl:with-param name="new_type_houdini_preview">double</xsl:with-param>
			<xsl:with-param name="new_name_ogl">ogl_ior</xsl:with-param>
			<xsl:with-param name="new_value">0.0</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="write_input">
			<xsl:with-param name="new_name">specular</xsl:with-param>
			<xsl:with-param name="new_type">float</xsl:with-param>
			<xsl:with-param name="new_type_houdini_preview">double</xsl:with-param>
			<xsl:with-param name="new_name_ogl">ogl_ior</xsl:with-param>
			<xsl:with-param name="new_value" select="./specAmt/@value"/>
		</xsl:call-template>
	</xsl:if>
	<xsl:if test="./useRefIdx[@value='1']">
		<xsl:call-template name="write_input">
			<xsl:with-param name="new_name">specular_IOR</xsl:with-param>
			<xsl:with-param name="new_type">float</xsl:with-param>
			<xsl:with-param name="new_type_houdini_preview">double</xsl:with-param>
			<xsl:with-param name="new_name_ogl">ogl_ior</xsl:with-param>
			<xsl:with-param name="new_value" select="./refIndex/@value"/>
		</xsl:call-template>
		<xsl:call-template name="write_input">
			<xsl:with-param name="new_name">specular</xsl:with-param>
			<xsl:with-param name="new_type">float</xsl:with-param>
			<xsl:with-param name="new_type_houdini_preview">double</xsl:with-param>
			<xsl:with-param name="new_name_ogl">ogl_spec_intensity</xsl:with-param>
			<xsl:with-param name="new_value" select="./specFres/@value"/>
		</xsl:call-template>
	</xsl:if>

	<xsl:for-each select="*">
		<xsl:variable name="old_type">
			<xsl:choose>
				<xsl:when test="@evaltype='color3'">color3f</xsl:when>
				<xsl:when test="@evaltype='percent'">float </xsl:when>
				<xsl:when test="@evaltype='distance'">float</xsl:when>
				<xsl:when test="@evaltype='boolean'">integer</xsl:when>
				<xsl:when test="@evaltype='integer'">float</xsl:when>
				<xsl:when test="@evaltype='float'">float</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="old_type_houdini_previeww">
			<xsl:choose>
				<xsl:when test="@evaltype='color3'">double3</xsl:when>
				<xsl:when test="@evaltype='percent'">double</xsl:when>
				<xsl:when test="@evaltype='distance'">double</xsl:when>
				<xsl:when test="@evaltype='boolean'">integer</xsl:when>
				<xsl:when test="@evaltype='integer'">double</xsl:when>
				<xsl:when test="@evaltype='float'">double </xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="old_name">
			<xsl:choose>
				<xsl:when test="name(.)='diffAmt'">base</xsl:when>
				<xsl:when test="name(.)='diffCol'">base_color</xsl:when>
				<xsl:when test="name(.)='coatAmt'">coat</xsl:when>
				<xsl:when test="name(.)='coatRough'">coat_roughness</xsl:when>
				<xsl:when test="name(.)='luminousAmt'">emission</xsl:when>
				<xsl:when test="name(.)='luminousCol'">emission_color</xsl:when>
				<xsl:when test="name(.)='metallic'">metalness</xsl:when>
				<xsl:when test="name(.)='specCol'">specular_color</xsl:when>
				<xsl:when test="name(.)='rough'">specular_roughness</xsl:when>
				<xsl:when test="name(.)='tranAmt'">transmission</xsl:when>
				<xsl:when test="name(.)='aniso'">specular_anisotropy</xsl:when>
				<xsl:when test="name(.)='rough'">diffuse_roughness</xsl:when>
				<xsl:when test="name(.)='tranCol'">transmission_color</xsl:when>
				<xsl:when test="name(.)='tranDist'">transmission_depth</xsl:when>
				<xsl:when test="name(.)='scatterAmt'">transmission_scatter</xsl:when>
				<xsl:when test="name(.)='disperse'">transmission_dispersion</xsl:when>
				<xsl:when test="name(.)='tranRough'">transmission_extra_roughness</xsl:when>
				<xsl:when test="name(.)='subsAmt'">subsurface</xsl:when>
				<xsl:when test="name(.)='subsCol'">subsurface_color</xsl:when>
				<xsl:when test="name(.)='subsDepth'">subsurface_radius</xsl:when>
				<xsl:when test="name(.)='subsDist'">subsurface_scale</xsl:when>
				<xsl:when test="name(.)='sheen'">sheen</xsl:when>
				<xsl:when test="name(.)='sheenTint'">sheen_color</xsl:when>
				<xsl:when test="name(.)='opacity'">opacity</xsl:when>
				<!-- Ignore
				<xsl:when test="name(.)='specAmt'">specular</xsl:when>
				<xsl:when test="name(.)='useRefIdx'">specular_rotation</xsl:when>
				<xsl:when test="name(.)='coatAmt'">transmission_scatter_anisotropy</xsl:when>
				<xsl:when test="name(.)='coatAmt'">subsurface_anisotropy</xsl:when>
				<xsl:when test="name(.)='coatAmt'">sheen_roughness</xsl:when>
				<xsl:when test="name(.)='coatAmt'">coat_color</xsl:when>
				<xsl:when test="name(.)='coatAmt'">coat_anisotropy</xsl:when>
				<xsl:when test="name(.)='coatAmt'">coat_rotation</xsl:when>
				<xsl:when test="name(.)='coatAmt'">coat_IOR</xsl:when>
				<xsl:when test="name(.)='coatAmt'">coat_normal</xsl:when>
				<xsl:when test="name(.)='coatAmt'">coat_affect_color</xsl:when>
				<xsl:when test="name(.)='coatAmt'">coat_affect_roughness</xsl:when>
				<xsl:when test="name(.)='coatAmt'">thin_film_thickness</xsl:when>
				<xsl:when test="name(.)='coatAmt'">thin_film_IOR</xsl:when>
				<xsl:when test="name(.)='coatAmt'">thin_walled</xsl:when>
				<xsl:when test="name(.)='coatAmt'">normal</xsl:when>
				<xsl:when test="name(.)='coatAmt'">tangent</xsl:when>

				<xsl:otherwise><xsl:value-of select="name(.)"/></xsl:otherwise>
				-->
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="old_name_ogl">
			<xsl:choose>
				<xsl:when test="name(.)='opacity'">ogl_diff_intensity</xsl:when>
				<xsl:when test="name(.)='diffCol'">ogl_diff</xsl:when>
				<xsl:when test="name(.)='coatAmt'">ogl_coat_intensity</xsl:when>
				<xsl:when test="name(.)='coatRough'">ogl_coat_rough</xsl:when>
				<xsl:when test="name(.)='luminousAmt'">ogl_emit_intensity</xsl:when>
				<xsl:when test="name(.)='luminousCol'">eogl_emit</xsl:when>
				<xsl:when test="name(.)='metallic'">ogl_metallic</xsl:when>
				<xsl:when test="name(.)='specCol'">ogl_spec</xsl:when>
				<xsl:when test="name(.)='rough'">ogl_rough</xsl:when>
				<xsl:when test="name(.)='tranAmt'">ogl_transparency</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="old_value" >
			<xsl:choose>
				<xsl:when test="@evaltype='color3'">(<xsl:value-of select="@r"/>, <xsl:value-of select="@g"/>, <xsl:value-of select="@b"/>)</xsl:when>
				<xsl:when test="@evaltype='vector3'">(<xsl:value-of select="@x"/>, <xsl:value-of select="@y"/>, <xsl:value-of select="@z"/>)</xsl:when>
				<xsl:when test="@evaltype='vector2'">(<xsl:value-of select="@u"/>, <xsl:value-of select="@v"/>)</xsl:when>
				<xsl:otherwise><xsl:value-of select="@value"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="write_input">
			<xsl:with-param name="new_type" select="$old_type"/>
			<xsl:with-param name="new_type_houdini_preview" select="$old_type_houdini_previeww"/>
			<xsl:with-param name="new_name" select="$old_name"/>
			<xsl:with-param name="new_name_ogl" select="$old_name_ogl"/>
			<xsl:with-param name="new_value" select="$old_value"/>
		</xsl:call-template>
	</xsl:for-each>
</xsl:template>

<xsl:template name="write_input">
	<xsl:param name="new_type"/>
	<xsl:param name="new_type_houdini_preview"/>
	<xsl:param name="new_name"/>
	<xsl:param name="new_name_ogl"/>
	<xsl:param name="new_value"/>
	<xsl:variable name="cr"><xsl:text>&#10;</xsl:text></xsl:variable>
	<xsl:variable name="tab-input"><xsl:text>				</xsl:text></xsl:variable>
	<xsl:if test="$new_name != ''">
		<xsl:choose>
			<xsl:when test="$new_name_ogl = ''">
				<xsl:value-of select="$cr"/><xsl:value-of select="$tab-input"/>
				<xsl:value-of select="$new_type"/> inputs:<xsl:value-of select="$new_name"/> = <xsl:value-of select="$new_value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$cr"/><xsl:value-of select="$tab-input"/>
				<xsl:value-of select="$new_type"/> inputs:<xsl:value-of select="$new_name"/> = <xsl:value-of select="$new_value"/> (
					customData = {
						dictionary HoudiniPreviewTags = {
							<xsl:value-of select="$new_type_houdini_preview"/> default_value = <xsl:value-of select="$new_value"/>
							string <xsl:value-of select="$new_name_ogl"/> = "1"
						}
					}
				)
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>