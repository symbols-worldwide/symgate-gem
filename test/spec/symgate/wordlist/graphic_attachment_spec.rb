require_relative '../../spec_helper.rb'

require 'symgate/wordlist/graphic_attachment'
require 'base64'

RSpec.describe(Symgate::Wordlist::GraphicAttachment) do
  it 'allows access to type, uuid and data' do
    k = get_kitten
    u = '7d18fe70-5342-0134-9ec0-20cf302b46f2'

    d = Symgate::Wordlist::GraphicAttachment.new
    d.type = 'image/jpeg'
    d.uuid = u
    d.data = k

    expect(d.type).to eq('image/jpeg')
    expect(d.uuid).to eq(u)
    expect(d.data).to eq(k)
  end

  it 'allows construction from a hash' do
    k = get_kitten
    u = '7d18fe70-5342-0134-9ec0-20cf302b46f2'

    d = Symgate::Wordlist::GraphicAttachment.new(type: 'image/jpeg',
                                                 uuid: u,
                                                 data: k)

    expect(d.type).to eq('image/jpeg')
    expect(d.uuid).to eq(u)
    expect(d.data).to eq(k)
  end

  it 'allows comparison with another GraphicAttachment' do
    u = '7d18fe70-5342-0134-9ec0-20cf302b46f2'
    k = get_kitten
    u2 = '910a4870-5342-0134-9ec0-20cf302b46f2'
    k2 = get_kitten :alternate

    g = Symgate::Wordlist::GraphicAttachment.new(type: 'image/jpeg',
                                                 uuid: u,
                                                 data: k)

    g2 = g.dup

    check_comparison_operator_for_member(g, g2, :type, 'image/png', 'image/jpeg')
    check_comparison_operator_for_member(g, g2, :uuid, u2, u)
    check_comparison_operator_for_member(g, g2, :data, k2, k)
  end

  it 'raises an error when created with an unknown parameter' do
    expect { Symgate::Wordlist::GraphicAttachment.new(teapot: false) }
      .to raise_error(Symgate::Error)
  end

  it 'generates a string summary of the object' do
    k = get_kitten
    u = '7d18fe70-5342-0134-9ec0-20cf302b46f2'

    d = Symgate::Wordlist::GraphicAttachment.new(type: 'image/jpeg',
                                                 uuid: u,
                                                 data: k)

    expect(d.to_s).to be_a(String)
    expect(d.to_s).to include('image/jpeg')
    expect(d.to_s).to include('7d18fe70-5342-0134-9ec0-20cf302b46f2')
    expect(d.to_s).to include('11824 bytes')
  end

  it 'base64-encodes the file data when converting to soap format' do
    k = get_kitten
    u = '7d18fe70-5342-0134-9ec0-20cf302b46f2'

    d = Symgate::Wordlist::GraphicAttachment.new(type: 'image/jpeg',
                                                 uuid: u,
                                                 data: k)

    expect(d.to_soap[:'wl:data']).to eq(Base64.encode64(k))
    expect(d.to_soap).not_to have_key(:'wl:uri')
  end

  it 'serialises a uri instead of data when a uri is set' do
    attachment = Symgate::Wordlist::GraphicAttachment.new(type: 'image/png',
                                                          uuid: '7d18fe70-5342-0134-9ec0-20cf302b46f2',
                                                          data: get_kitten,
                                                          uri: 'model:cat.png')

    expect(attachment.to_soap).to eq(%s(wl:type) => 'image/png',
                                     %s(wl:uuid) => '7d18fe70-5342-0134-9ec0-20cf302b46f2',
                                     %s(wl:uri) => 'model:cat.png')
  end

  it 'reads a uri from a soap hash' do
    attachment = Symgate::Wordlist::GraphicAttachment.from_soap(
      type: 'image/svg+xml',
      uuid: '7d18fe70-5342-0134-9ec0-20cf302b46f2',
      uri: 'model:cat.svg'
    )

    expect(attachment.uri).to eq('model:cat.svg')
    expect(attachment.data).to be_nil
  end

  it 'describes an attachment that has a uri and no data' do
    attachment = Symgate::Wordlist::GraphicAttachment.new(type: 'image/png',
                                                          uuid: '7d18fe70-5342-0134-9ec0-20cf302b46f2',
                                                          uri: 'model:cat.png')

    expect(attachment.to_s).to include('model:cat.png')
    expect(attachment.to_s).to include('image/png')
  end

  it 'describes an attachment with no data or uri' do
    attachment = Symgate::Wordlist::GraphicAttachment.new(type: 'image/png',
                                                          uuid: '7d18fe70-5342-0134-9ec0-20cf302b46f2')

    expect(attachment.to_s).to include('no data')
  end
end
