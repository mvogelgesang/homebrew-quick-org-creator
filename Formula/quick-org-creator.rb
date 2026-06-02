class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.6.0.tar.gz"
  # LOCAL sha256 "6cfc69d986206b3619f92fc4d3fa194c048daa59dd6e0c46579278c413035f98"
  url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.6.0.tar.gz"
  version "0.6.0"
  sha256 "6cfc69d986206b3619f92fc4d3fa194c048daa59dd6e0c46579278c413035f98"
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
