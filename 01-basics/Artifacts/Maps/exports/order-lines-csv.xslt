<?xml version="1.0" encoding="utf-8"?>
<!-- Order lines to CSV (RFC 4180): a header row, then one row per line. Text fields are quoted and quotes doubled. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="utf-8"/>

  <xsl:variable name="nl" select="'&#10;'"/>
  <xsl:variable name="quote">"</xsl:variable>

  <xsl:template match="/Order">
    <xsl:text>order,line,sku,description,quantity,unit_price</xsl:text>
    <xsl:value-of select="$nl"/>
    <xsl:variable name="order" select="normalize-space(Number)"/>
    <xsl:for-each select="Lines/Line">
      <xsl:value-of select="concat($order, ',', position(), ',', normalize-space(Sku), ',')"/>
      <xsl:call-template name="quoted">
        <xsl:with-param name="text" select="Description"/>
      </xsl:call-template>
      <xsl:value-of select="concat(',', Quantity, ',', format-number(UnitPrice, '0.00'), $nl)"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="quoted">
    <xsl:param name="text"/>
    <xsl:value-of select="$quote"/>
    <xsl:call-template name="double-quotes">
      <xsl:with-param name="text" select="$text"/>
    </xsl:call-template>
    <xsl:value-of select="$quote"/>
  </xsl:template>

  <!-- XSLT 1.0 has no replace(): recurse on the first quote. -->
  <xsl:template name="double-quotes">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="contains($text, $quote)">
        <xsl:value-of select="concat(substring-before($text, $quote), $quote, $quote)"/>
        <xsl:call-template name="double-quotes">
          <xsl:with-param name="text" select="substring-after($text, $quote)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
