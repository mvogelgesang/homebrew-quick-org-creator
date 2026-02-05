class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.5.0.tar.gz"
  # LOCAL sha256 "d3f8894f50c7f27736f76e58b187f5e48c19f1cc7f98c3451f88dcc7f01ea127"
  url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.5.0.tar.gz"
  version "0.5.0"
  sha256 "d3f8894f50c7f27736f76e58b187f5e48c19f1cc7f98c3451f88dcc7f01ea127"
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
