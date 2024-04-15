# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class QuickOrgCreator < Formula
  desc "A script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  url "https://github.com/mvogelgesang/homebrew-quick-org-creator/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "a09c574f9253d4c6f4e3487d8dcb375180aa6a685042fb5570b920aad00b0513"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  def install
    libexec.install Dir[*]
    bin.write_exec_script (libexec/"src/run.sh") => "oc"
  end

  test do
    system "#{bin}/oc", "namespace"
  end
end
