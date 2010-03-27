class FakeDefensio
  def post_document(data)
    content = data[:content] || data['content']
    classification, spaminess = content[1..-2].split(',')
    [200, {
      'api-version' => '2.0',
      'status' => 'success',
      'message' => '',
      'signature' => 'blablabla',
      'allow' => (classification == 'innocent'),
      'classification' => classification,
      'spaminess' => spaminess.to_f,
      'profanity-match' => false
    }]
  end
end
