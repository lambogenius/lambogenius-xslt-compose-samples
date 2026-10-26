<?xml version="1.0" encoding="utf-8"?>
<!--
  Shared module, imported by orders/order-to-sales-order.xslt. Deployed maps can include and import other maps by
  relative path; inline maps cannot.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Trims a code and upper-cases it: " abc-01 " becomes "ABC-01". -->
  <xsl:template name="normalize-code">
    <xsl:param name="value"/>
    <xsl:value-of select="translate(normalize-space($value), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
  </xsl:template>

  <!-- Money with two decimals. -->
  <xsl:template name="money">
    <xsl:param name="amount"/>
    <xsl:value-of select="format-number($amount, '0.00')"/>
  </xsl:template>
</xsl:stylesheet>
