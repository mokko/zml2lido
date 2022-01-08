<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!-- 1.1 objectMeasurementSet
	Contains information about the dimensions, or other measurements, of the
	object/work in focus; implies spacial, temporal or quantitative extent.
		measurementType
		measurementUnit
		measurementValue
	-->

	<xsl:template name="objectMeasurementsWrap">
		<lido:objectMeasurementsWrap>
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjDimAllGrp']/z:repeatableGroupItem"/>
		</lido:objectMeasurementsWrap>
    </xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjDimAllGrp']/z:repeatableGroupItem">
		<lido:objectMeasurementsSet>
			<xsl:if test="normalize-space(z:virtualField[@name='PreviewVrt']/z:value) != ''">
				<lido:displayObjectMeasurements>
					<!-- use PreviewENVrt? -->
					<xsl:value-of select="z:virtualField[@name='PreviewVrt']/z:value"/>
				</lido:displayObjectMeasurements>
			</xsl:if>
			<lido:objectMeasurements>
				<lido:measurementsSet>
					<lido:measurementType>
						<xsl:value-of select="z:moduleReference[@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue"/>
					</lido:measurementType>
					<lido:measurementUnit>
						<xsl:value-of select="z:vocabularyReference[@name='UnitDdiVoc']/z:vocabularyReferenceItem/@name"/>
					</lido:measurementUnit>
					<lido:measurementValue>
						<xsl:apply-templates select="z:moduleReference[@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue"/>
					</lido:measurementValue>
				</lido:measurementsSet>
			</lido:objectMeasurements>
		</lido:objectMeasurementsSet>
	</xsl:template>

	<xsl:template match="z:moduleReference[@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue">
		<xsl:choose>
			<xsl:when test=". = 'Andere Maße'">
				<xsl:value-of select="../../../z:dataField[@name='Unknown3Num']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='Unknown1Num']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='Unknown2Num']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Auflagekarton'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Allgemein'">
				<xsl:value-of select="../../../z:dataField[@name='Unknown1Num']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='Unknown2Num']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Bemalte Bildfläche'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Bildformat (Foto)'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Bildmaß'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Blattmaß'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Breite'">
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Dauer'">
				<xsl:value-of select="format-number(../../../z:dataField[@name='HoursLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='MinutesLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='SecondsLnu']/z:value, '00')"/>
			</xsl:when>
			<!--todo: no value; might need correction upstream in RIA -->
			<xsl:when test=". = 'Diaformat'">
				<xsl:value-of select="../../../z:dataField[@name='ThicknessNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Dicke'">
				<xsl:value-of select="../../../z:dataField[@name='ThicknessNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Durchmesser'">
				<xsl:value-of select="../../../z:dataField[@name='DiameterNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Durchmesser x Tiefe'">
				<xsl:value-of select="../../../z:dataField[@name='DiameterNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='DepthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Fläche'">
				<xsl:value-of select="../../../z:dataField[@name='Unknown1Num']/z:value"/>
			</xsl:when>
			<!-- Walze ist unnötig; todo: in RIA korrigieren -->
			<xsl:when test=". = 'Geschwindigkeit'">
				<xsl:value-of select="../../../z:dataField[@name='SpeedNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Geschwindigkeit (Band)'">
				<xsl:value-of select="../../../z:dataField[@name='SpeedNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Geschwindigkeit (Walze)'">
				<xsl:value-of select="../../../z:dataField[@name='SpeedNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Gewicht'">
				<xsl:value-of select="../../../z:dataField[@name='WeightNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Höhe'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Höhe x Breite'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Höhe x Breite x Stärke'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='ThicknessNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Höhe x Breite x Tiefe'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='DepthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Höhe x Durchmesser'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='DiameterNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Kartonformat'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Kartonformat (Foto)'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Länge'">
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Länge x Breite'">
				<xsl:value-of select="../../../z:dataField[@name='LengthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Länge x Breite x Höhe'">
				<xsl:value-of select="../../../z:dataField[@name='LengthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Länge x Breite x Tiefe'">
				<xsl:value-of select="../../../z:dataField[@name='DepthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='LengthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Länge x Durchmesser'">
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='DiameterNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Objektmaß'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='DepthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Passepartout'">
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Passepartoutmaß'">
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Rahmenmaß'">
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Rahmenaußenmaß'">
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Sehnenlänge'">
				<xsl:value-of select="../../../z:dataField[@name='Unknown1Num']/z:value"/>
			</xsl:when>
			<!-- Synonym with Dauer; replace with pref in RIA-->
			<xsl:when test=". = 'Spieldauer'">
				<xsl:value-of select="format-number(../../../z:dataField[@name='HoursLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='MinutesLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='SecondsLnu']/z:value, '00')"/>
			</xsl:when>
			<!-- only instance of Stichmaß has no value; todo-->
			<xsl:when test=". = 'Stichmaß'">
				<xsl:value-of select="../../../z:dataField[@name='Unknown1Num']/z:value"/>
			</xsl:when>
			
			<xsl:when test=". = 'Tiefe'">
				<xsl:value-of select="../../../z:dataField[@name='DepthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Umfang'">
				<xsl:value-of select="../../../z:dataField[@name='CircumferenceNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Verpackungsmaß'">
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='DepthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Volumen'">
				<xsl:value-of select="../../../z:dataField[@name='VolumeNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Wandstärke' or  . = 'Wandungsstärke'">
				<xsl:value-of select="../../../z:dataField[@name='DiameterNum']/z:value"/>
			</xsl:when>
			<!-- DONT OUTPUT ANYTHING, BUT DONT DIE EITHER-->
			<xsl:when test=". = 'Leer'"/>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>Unbekannter Maßtyp: </xsl:text>
					<xsl:value-of select="."/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>