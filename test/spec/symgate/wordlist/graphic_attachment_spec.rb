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
  end
end
