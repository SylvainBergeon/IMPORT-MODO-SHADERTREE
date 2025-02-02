<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:math="http://www.w3.org/2005/xpath-functions/math"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">

    <xsl:output method="xml" indent="yes" suppress-indentation="input"/>
    <!--<xsl:mode on-no-match="shallow-copy"/>-->

    <xsl:template match="/">
        <materialx version="major.minor" colorspace="lin_rec709" namespace="">
                <xsl:apply-templates select="*"/>
        </materialx>
    </xsl:template>

    <xsl:template match="advancedMaterial">
        <nodegraph name="NG_mtlxmaterial_surfaceshader_displacementshader">
        <standard_surface type="surfaceshader">
            <xsl:attribute name="name" select="@id"/>
            <xsl:apply-templates select="*"/>
        </standard_surface>
        <output name="surface" type="surfaceshader">
             <xsl:attribute name="nodename" select="@id"/>
        </output>
        <displacement name="displacement" type="displacementshader">
            <input name="displacement" type="float" value="0" />
            <input name="scale" type="float" value="1" />
        </displacement>
        <output name="displacement2" type="displacementshader" nodename="displacement" />
        </nodegraph>
    
    </xsl:template>

    <xsl:template match="channels">
        <xsl:for-each select="*">
            <input>
                <xsl:attribute name="type" select="@type"/>
                <xsl:attribute name="name">
                    <xsl:choose>
                        <xsl:when test="name(.)='?'">base</xsl:when>
                        <xsl:when test="name(.)='diffCol'">base_color</xsl:when>
                        <xsl:when test="name(.)='rough'">diffuse_roughness</xsl:when>
                        <xsl:when test="name(.)='metallic'">metalness</xsl:when>
                        <xsl:when test="name(.)='specAmt'">specular</xsl:when>
                        <xsl:when test="name(.)='specCol'">specular_color</xsl:when>
                        <xsl:when test="name(.)='rough'">specular_roughness</xsl:when>
                        <xsl:when test="name(.)='refIndex'">specular_IOR</xsl:when>
                        <xsl:when test="name(.)='aniso'">specular_anisotropy</xsl:when>
                        <xsl:when test="name(.)='tranAmt'">transmission</xsl:when>
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
                        <xsl:when test="name(.)='coatAmt'">coat</xsl:when>
                        <xsl:when test="name(.)='coatRough'">coat_roughness</xsl:when>
                        <xsl:when test="name(.)='luminousAmt'">emission</xsl:when>
                        <xsl:when test="name(.)='luminousCol'">emission_color</xsl:when>
                        <xsl:when test="name(.)='opacity'">opacity</xsl:when>
                        <xsl:otherwise><xsl:value-of select="name(.)"/></xsl:otherwise>
                        <!--<xsl:when test="name(.)='coatAmt'">specular_rotation</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">transmission_scatter_anisotropy</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">subsurface_anisotropy</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">sheen_roughness</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">coat_color</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">coat_anisotropy</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">coat_rotation</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">coat_IOR</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">coat_normal</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">coat_affect_color</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">coat_affect_roughness</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">thin_film_thickness</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">thin_film_IOR</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">thin_walled</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">normal</xsl:when>-->
                        <!--<xsl:when test="name(.)='coatAmt'">tangent</xsl:when>-->
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="value" >
                    <xsl:choose>
                        <xsl:when test="@evaltype='color3'">
                            <xsl:value-of select="@r"/>, <xsl:value-of select="@g"/>, <xsl:value-of select="@b"/>
                        </xsl:when>
                        <xsl:when test="@evaltype='vector3'">
                            <xsl:value-of select="@x"/>, <xsl:value-of select="@y"/>, <xsl:value-of select="@z"/>
                        </xsl:when>
                        <xsl:when test="@evaltype='vector2'">
                            <xsl:value-of select="@u"/>, <xsl:value-of select="@v"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </input>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>