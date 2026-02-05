class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.4.4.tar.gz"
  # LOCAL sha256 "dd86526fba162fbdf592f1fed0a2c69ed5b4da7cd0cfa6a3eb925cd114e09b8a"
  url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.4.4.tar.gz"
  version "0.4.4"
  sha256 "dd86526fba162fbdf592f1fed0a2c69ed5b4da7cd0cfa6a3eb925cd114e09b8a"
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
