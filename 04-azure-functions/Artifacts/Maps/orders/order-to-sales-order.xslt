<?xml version="1.0" encoding="utf-8"?>
<!--
  Everything together: an imported module, a C# helper and an Azure Function call.

  az:InvokeText('GetCustomerName', value) POSTs {"value": "<value>"} to the Function registered as GetCustomerName in
  xslt-functions.json and returns its text answer. Any prefix bound to urn:lambogenius:azure-functions works.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    xmlns:code="urn:lambogenius:code"
    xmlns:az="urn:lambogenius:azure-functions"
    exclude-result-prefixes="msxsl code az">

  <xsl:import href="../common/normalize.xslt"/>

  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="yes"/>

  <xsl:param name="currency" select="'CAD'"/>

  <msxsl:script language="C#" implements-prefix="code">
    <![CDATA[
      public string Money(double amount)
      {
          return amount.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture);
      }
    ]]>
  </msxsl:script>

  <xsl:template match="/Order">
    <SalesOrder>
      <OrderNumber>
        <xsl:call-template name="normalize-code">
          <xsl:with-param name="value" select="Number"/>
        </xsl:call-template>
      </OrderNumber>
      <Customer>
        <Id><xsl:value-of select="CustomerId"/></Id>
        <Name><xsl:value-of select="az:InvokeText('GetCustomerName', string(CustomerId))"/></Name>
      </Customer>
      <Currency><xsl:value-of select="$currency"/></Currency>
      <Lines>
        <xsl:for-each select="Lines/Line">
          <Line>
            <Sku>
              <xsl:call-template name="normalize-code">
                <xsl:with-param name="value" select="Sku"/>
              </xsl:call-template>
            </Sku>
            <Quantity><xsl:value-of select="Quantity"/></Quantity>
            <Amount><xsl:value-of select="code:Money(Quantity * UnitPrice)"/></Amount>
          </Line>
        </xsl:for-each>
      </Lines>
    </SalesOrder>
  </xsl:template>
</xsl:stylesheet>
