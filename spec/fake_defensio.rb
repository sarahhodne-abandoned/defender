class FakeDefensio
  def initialize
    @documents = {}
  end

  def post_document(data)
    content = data[:content] || data['content']
    classification, spaminess = content[1..-2].split(',')
    signature = "#{rand}#{content}".hash

    @documents[signature] = {
      'api-version' => '2.0',
      'status' => 'success',
      'message' => '',
      'signature' => signature,
      'allow' => (classification == 'innocent'),
      'classification' => classification,
      'spaminess' => spaminess.to_f,
      'profanity-match' => false
    }

    [200, @documents[signature]]
  end

  def get_document(signature)
    if @documents.has_key?(signature)
      [200, @documents[signature]]
    else
      [404,
        'api-version' => '2.0',
        'status' => 'failure',
        'message' => 'document not found'
      ]
    end
  end
end
