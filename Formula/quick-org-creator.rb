class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.3.7.tar.gz"
  # LOCAL sha256 "b19e119c4740c042897f48e3aacfbe04dbb611b402608761d96906071e025e44"
  version File.read("VERSION").strip
  url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.3.7.tar.gz"
  sha256 "b19e119c4740c042897f48e3aacfbe04dbb611b402608761d96906071e025e44"
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
