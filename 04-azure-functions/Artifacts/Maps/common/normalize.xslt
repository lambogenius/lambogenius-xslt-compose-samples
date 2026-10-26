<?xml version="1.0" encoding="utf-8"?>
<!-- Shared module: trims a code and upper-cases it. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template name="normalize-code">
    <xsl:param name="value"/>
    <xsl:value-of select="translate(normalize-space($value), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
  </xsl:template>
</xsl:stylesheet>
