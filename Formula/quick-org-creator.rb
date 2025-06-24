class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.4.0.tar.gz"
  # LOCAL sha256 "b70ee21b417ee7cf32615330f494a14fc879d9a41bdfb0005ec1d65e37f29ab6"
  version File.read("VERSION").strip
  url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "b70ee21b417ee7cf32615330f494a14fc879d9a41bdfb0005ec1d65e37f29ab6"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  def install
    libexec.install Dir["src/*"]
    libexec.install Dir["fileTemplates/"]
    libexec.install Dir["..scratchDefs/"]
    libexec.install "VERSION"
    bin.install_symlink libexec/"run.sh" => "oc"
  end

  test do
    system "#{bin}/oc", "namespace"
  end
end
