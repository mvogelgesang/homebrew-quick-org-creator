class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.5.1.tar.gz"
  # LOCAL sha256 "663f7ce132f7f597fe7c973bbf13724fa1beda6b9259442f2b5a0a26a6dea8fb"
  url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.5.1.tar.gz"
  version "0.5.1"
  sha256 "663f7ce132f7f597fe7c973bbf13724fa1beda6b9259442f2b5a0a26a6dea8fb"
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
