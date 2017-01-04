xml.operation('xlmns' => 'http://www.easytrack.nl/integration/textmessaging/2011/02', 'xlmns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'http://www.easytrack.nl/integration/textmessaging/2011/02') {
  xml.operationId params[:operation_id]
  xml.asset {
    xml.code params[:asset][:code]
  }
  xml.send_ {
    xml.message {
      xml.code params[:message][:code]
      xml.content params[:message][:content]
      xml.timestamp params[:message][:timestamp]
    }
  }
}
