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
					<xsl:value-of select="normalize-space(z:virtualField[@name='PreviewVrt']/z:value)"/>
				</lido:displayObjectMeasurements>
			</xsl:if>
			<lido:objectMeasurements>
				<lido:measurementsSet>
					<lido:measurementType>
						<xsl:value-of select="normalize-space(z:moduleReference[
							@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue)"/>
					</lido:measurementType>
					<lido:measurementUnit>
						<xsl:value-of select="normalize-space(z:vocabularyReference[
							@name='UnitDdiVoc']/z:vocabularyReferenceItem/@name)"/>
					</lido:measurementUnit>
					<lido:measurementValue>
						<xsl:apply-templates select="normalize-space(z:moduleReference[
							@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue)"/>
					</lido:measurementValue>
				</lido:measurementsSet>
			</lido:objectMeasurements>
		</lido:objectMeasurementsSet>
	</xsl:template>

	<xsl:template match="z:moduleReference[@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue">
		<xsl:variable name="this" select="normalize-space(.)"/>
		<xsl:choose>
			<xsl:when test="$this eq 'Andere Ma??e'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown3Num']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown1Num']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown2Num']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Auflagekarton'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Au??enma??'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Allgemein'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown1Num']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown2Num']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Bemalte Bildfl??che'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Bildformat (Foto)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Bildma??'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Blattma??'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Breite'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Breite x Tiefe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Dauer'">
				<xsl:value-of select="format-number(../../../z:dataField[@name='HoursLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='MinutesLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='SecondsLnu']/z:value, '00')"/>
			</xsl:when>
			<!--todo: no value; might need correction upstream in RIA -->
			<xsl:when test="$this eq 'Diaformat'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='ThicknessNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Dicke'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='ThicknessNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Durchmesser'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Durchmesser (mit Dicke)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='ThicknessNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Durchmesser x Tiefe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Fl??che'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown1Num']/z:value)"/>
			</xsl:when>
			<!-- Walze ist unn??tig; todo: in RIA korrigieren -->
			<xsl:when test="$this eq 'Geschwindigkeit'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='SpeedNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Geschwindigkeit (Band)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='SpeedNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Geschwindigkeit (Schallplatte)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='SpeedNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Geschwindigkeit (Walze)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='SpeedNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Gewicht'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'H??he'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'H??he x Breite'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'H??he x Breite (aufgeschlagen)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'H??he x Breite x St??rke'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='ThicknessNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'H??he x Breite x Tiefe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'H??he x Durchmesser'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Kartonformat'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Kartonformat (Foto)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Kistenma??'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'L??nge'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'L??nge x Breite'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'L??nge x Breite x H??he'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'L??nge x Breite x Tiefe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'L??nge x Durchmesser'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'M??ndung'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Negativformat (Foto)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
			</xsl:when>			
			<xsl:when test="$this eq 'Montage'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Objektma??'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq '??ffnung'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Passepartout'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Passepartoutma??'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Passepartout Standardformat'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>			
			<xsl:when test="$this eq 'Plattengr????e (Foto)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Rahmenma??'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Rahmenau??enma??'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Sehnenl??nge'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown1Num']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Sockel'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<!-- Spieldauer is synonymous with Dauer; replace with pref in RIA-->
			<xsl:when test="$this eq 'Spieldauer'">
				<xsl:value-of select="format-number(../../../z:dataField[@name='HoursLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='MinutesLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='SecondsLnu']/z:value, '00')"/>
			</xsl:when>
			<!-- only instance of Stichma?? has no value; todo-->
			<xsl:when test="$this eq 'Stichma??'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown1Num']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Tiefe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Transportma??'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Umfang'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='CircumferenceNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Verpackungsma??'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Volumen'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='VolumeNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Wandst??rke' or  . = 'Wandungsst??rke'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<!-- DONT OUTPUT ANYTHING, BUT DONT DIE EITHER-->
			<xsl:when test="$this eq 'Leer'"/>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>ERROR: Unknown measurement type: </xsl:text>
					<xsl:value-of select="."/>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="../../../../../../@name"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="../../../../../@id"/>
					<xsl:text>)</xsl:text>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>