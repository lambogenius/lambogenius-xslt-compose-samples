<?xml version="1.0" encoding="utf-8"?>
<!-- The same order as one line of text, for the dynamic-map workflow's format=text. -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    exclude-result-prefixes="msxsl">
  <xsl:output method="text" encoding="utf-8"/>

  <xsl:template match="/Order">
    <xsl:variable name="amounts">
      <xsl:for-each select="Lines/Line">
        <amount><xsl:value-of select="Quantity * UnitPrice"/></amount>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="concat('Invoice for ', translate(normalize-space(Number), 'ord', 'ORD'), ': ', count(Lines/Line), ' lines, ',
      sum(Lines/Line/Quantity), ' units, subtotal ', format-number(sum(msxsl:node-set($amounts)/amount), '0.00'))"/>
  </xsl:template>
</xsl:stylesheet>
