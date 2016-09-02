require_relative '../../spec_helper.rb'

require 'symgate/wordlist/graphic_attachment'
require 'base64'

RSpec.describe(Symgate::Wordlist::GraphicAttachment) do
  def get_kitten(variation = :default)
    File.open(case variation
              when :alternate
                'test/spec/fixtures/kitten_2.jpg'
              else
                'test/spec/fixtures/kitten.jpg'
              end, 'rb').read
  end

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

    d = Symgate::Wordlist::GraphicAttachment.new(type: 'image/jpeg',
                                                 uuid: u,
                                                 data: k)

    d2 = Symgate::Wordlist::GraphicAttachment.new(type: 'image/png',
                                                  uuid: u2,
                                                  data: k2)

    expect(d == d2).to be_falsey

    d2.type = 'image/jpeg'
    expect(d == d2).to be_falsey

    d2.uuid = u
    expect(d == d2).to be_falsey

    d2.data = k
    expect(d == d2).to be_truthy
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

    expect(d.to_soap[:data]).to eq(Base64.encode64(k))
  end
end
