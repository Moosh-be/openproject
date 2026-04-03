# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe "i18n_keys:generate" do
  include_context "rake"

  let(:tmp_root) { Pathname.new(Dir.mktmpdir) }
  let(:locale_dir) { tmp_root.join("config", "locales") }
  let(:en_file) { locale_dir.join("en.yml") }
  let(:result_file) { locale_dir.join("i18n_keys.yml") }

  before do
    allow(Rails).to receive(:root).and_return(tmp_root)
    FileUtils.mkdir_p(locale_dir)

    en_file.write <<~YML
      en:
        foo:
          bar: "Hello"
        baz: "World"
    YML
  end

  after do
    FileUtils.rm_rf(tmp_root)
  end

  it "generates i18n_keys.yml from en.yml with dotted key values" do
    subject.invoke

    generated = YAML.safe_load(result_file.read)

    expect(generated).to eq(
      "i18n_keys" => {
        "foo" => { "bar" => "foo.bar" },
        "baz" => "baz"
      }
    )
  end
end
