<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<xsl:template name="resourceWrap">
        <xsl:variable name="objId" select="@objId" />
        <xsl:variable name="mmo" select="../multimediaobjekt[
            verknüpftesObjekt eq $objId and lower-case(veröffentlichen) eq 'ja']"/>
            <lido:resourceWrap>
                <xsl:apply-templates select="$mmo" />
            </lido:resourceWrap>
    </xsl:template>

    <xsl:template match="/museumPlusExport/multimediaobjekt">
        <xsl:variable name="objId" select="verknüpftesObjekt"/>
        <!-- 
            only export digital representations to LIDO, not purely analog ones 
            Don't record MM records with veröffentlichen = nein
            I would like to include veröffentlichen field into LIDO, but dont see where that fits
        -->
        <lido:resourceSet>
            <xsl:attribute name="lido:sortorder">
                <xsl:choose>
                    <xsl:when test="standardbild">1</xsl:when>
                    <xsl:otherwise><xsl:number/></xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <lido:resourceID lido:type="mulId">
            <!-- according to LIDO's pdf specification resourceID can have
                 attribute encodinganalog; according to xsd it can't have 
                 it. 
                <xsl:attribute name="encodinganalog">
                    <xsl:value-of select="pfadangabe"/>
                    <xsl:text>\</xsl:text>
                    <xsl:value-of select="dateiname"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="erweiterung"/>
                </xsl:attribute>
            -->
                <xsl:value-of select="@mulId" />
            </lido:resourceID>
            <lido:resourceRepresentation>
                <xsl:attribute name="lido:type" xml:lang="EN">
                    <xsl:choose>
                        <xsl:when test="lower-case(erweiterung) eq 'jpg'">
                            <xsl:text>Preview Representation</xsl:text>
                        </xsl:when>
                        <xsl:when test="lower-case(erweiterung) eq 'tif' or lower-case(erweiterung) eq 'tiff' ">
                            <xsl:text>Provided Representation</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message>
                                <xsl:text>Error: Unknown image type: </xsl:text>
                                <xsl:value-of select="erweiterung"/>
                            </xsl:message>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <lido:linkResource> 
                    <xsl:attribute name="lido:formatResource">
                        <xsl:value-of select="lower-case(erweiterung)"/>
                    </xsl:attribute>
                    <!-- xsl:text>../../pix2/xsl:text  -->
                    <xsl:value-of select="@mulId" />
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="dateiname"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="erweiterung"/>
                </lido:linkResource>
                    <!-- lido:resourceMeasurementsSet>
                        <lido:measurementType>width</lido:measurementType>
                        <lido:measurementUnit>pixel</lido:measurementUnit>
                        <lido:measurementValue>120</lido:measurementValue>
                    </lido:resourceMeasurementsSet -->
            </lido:resourceRepresentation>
            <xsl:if test="lower-case(erweiterung) = 'jpg' 
                or lower-case(erweiterung) = 'tif' 
                or lower-case(erweiterung) = 'tiff'">
                <lido:resourceType>
                    <!-- no voc at http://terminology.lido-schema.org 20200301 -->
                    <lido:term xml:lang="EN">digital image</lido:term>
                </lido:resourceType>
                <xsl:apply-templates select="inhaltAnsicht"/>
                <xsl:apply-templates select="anfertDat"/>
            </xsl:if>
            <xsl:if test="urhebFotograf">
                <lido:rightsResource>
                    <lido:rightsType>
                        <lido:term xml:lang="DE">Urheber</lido:term>
                    </lido:rightsType>
                    <lido:rightsHolder>
                        <lido:legalBodyName>
                            <lido:appellationValue>
                                <xsl:value-of select="urhebFotograf" />
                            </lido:appellationValue>
                        </lido:legalBodyName>
                    </lido:rightsHolder>
                </lido:rightsResource>
            </xsl:if>
            <lido:rightsResource>
                <lido:rightsType>
                    <lido:term>Nutzungsrechte</lido:term>
                </lido:rightsType>
                <lido:rightsHolder>
                    <lido:legalBodyName>
                        <lido:appellationValue>
                            <xsl:text>Staatliche Museen zu Berlin, Preußischer Kulturbesitz</xsl:text>
                        </lido:appellationValue>
                    </lido:legalBodyName>
                </lido:rightsHolder>

                <!-- 
                TODO: Not sure how FD wants the the creditline to be formated; 
                Currently, I am adapting credits in smb.digital.de, but not exactly. 
                -->
                <lido:creditLine>
                    <xsl:if test="urhebFotograf">
                        <xsl:text>Foto: </xsl:text>
                        <xsl:value-of select="urhebFotograf"/>
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="../sammlungsobjekt[@objId eq $objId]/verwaltendeInstitution"/>
                    <xsl:text> - Preußischer Kulturbesitz</xsl:text>
                </lido:creditLine>
            </lido:rightsResource>
        </lido:resourceSet>
    </xsl:template>

    <xsl:template match="inhaltAnsicht">
                <lido:resourceDescription>
                    <xsl:value-of select="."/>
                </lido:resourceDescription>
	</xsl:template>

    <!-- 
        resourceDateTaken is part of xsd, given in LIDO examples, but not 
        part in pdf specification -->
    <xsl:template match="anfertDat">
        <lido:resourceDateTaken>
            <lido:displayDate>
                <xsl:value-of select="."/>
            </lido:displayDate>
        </lido:resourceDateTaken> 
    </xsl:template>
</xsl:stylesheet>
