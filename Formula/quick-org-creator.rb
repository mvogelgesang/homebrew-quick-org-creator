class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.3.6.tar.gz"
  # LOCAL sha256 "3d6946536a18f582516e63f4210a6a41116f08447e86df9c20f32cab9014fdc9"
  version File.read("VERSION").strip
  url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.3.6.tar.gz"
  sha256 "3d6946536a18f582516e63f4210a6a41116f08447e86df9c20f32cab9014fdc9"
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
