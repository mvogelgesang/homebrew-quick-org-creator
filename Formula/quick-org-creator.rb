class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.4.3.tar.gz"
  # LOCAL sha256 "7fa2b16bd0717cc877c430f4001e617557f2b25db6233c8067472a936f421bbf"
  url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.4.3.tar.gz"
  version "0.4.3"
  sha256 "7fa2b16bd0717cc877c430f4001e617557f2b25db6233c8067472a936f421bbf"
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
