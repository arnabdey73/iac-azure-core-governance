from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RGBColor

prs = Presentation()

# Title Slide
slide = prs.slides.add_slide(prs.slide_layouts[0])
title = slide.shapes.title
title.text = "Azure Governance Solution"
subtitle = slide.placeholders[1]
subtitle.text = "Secure, Compliant, and Scalable Cloud Adoption\nYour Company Name\nMay 28, 2025"

# Why Azure Governance?
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "Why Azure Governance?"
content = (
    "Cloud adoption brings agility, but also risk\n"
    "- Uncontrolled resource sprawl\n"
    "- Security & compliance gaps\n"
    "- Cost overruns\n\n"
    "Governance ensures control, security, and efficiency."
)
slide.placeholders[1].text = content

# What is Azure Governance?
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "What is Azure Governance?"
content = (
    "Framework of policies, processes, and controls for managing Azure resources.\n\n"
    "Key pillars:\n"
    "- Management Groups & Hierarchy\n"
    "- Policy & Compliance\n"
    "- Role-Based Access Control (RBAC)\n"
    "- Security & Monitoring"
)
slide.placeholders[1].text = content

# Our Approach
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "Our Approach"
content = (
    "- Enterprise-scale landing zone architecture\n"
    "- Automated deployment with Infrastructure as Code (Terraform)\n"
    "- Modular, reusable, and customizable\n"
    "- Continuous compliance and monitoring"
)
slide.placeholders[1].text = content

# Core Components
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "Core Components"
content = (
    "- Management Group Hierarchy: Organize subscriptions for policy inheritance\n"
    "- Azure Policies: Enforce standards (e.g., tagging, allowed locations)\n"
    "- RBAC: Least-privilege access, custom roles\n"
    "- Security Center: Threat protection & compliance\n"
    "- Monitoring: Centralized logging & alerting"
)
slide.placeholders[1].text = content

# Key Benefits
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "Key Benefits"
content = (
    "- Accelerated cloud adoption\n"
    "- Reduced risk & improved compliance\n"
    "- Cost control & resource optimization\n"
    "- Scalable and repeatable deployments"
)
slide.placeholders[1].text = content

# Customer Success Story (Optional)
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "Customer Success Story"
content = (
    "- Brief case study or testimonial\n"
    "- Before & after metrics\n"
    "(Add your customer story here)"
)
slide.placeholders[1].text = content

# How We Deliver
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "How We Deliver"
content = (
    "- Assessment & design\n"
    "- Automated deployment (CI/CD pipelines)\n"
    "- Knowledge transfer & documentation\n"
    "- Ongoing support"
)
slide.placeholders[1].text = content

# Next Steps
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "Next Steps"
content = (
    "- Discovery workshop\n"
    "- Proof of concept\n"
    "- Full-scale rollout"
)
slide.placeholders[1].text = content

# Q&A / Contact
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "Q&A / Contact"
content = (
    "Thank you!\n\n"
    "Contact us for more information:\n"
    "your.email@company.com"
)
slide.placeholders[1].text = content

prs.save("Azure-Governance-Solution-Presentation.pptx")
print("Presentation created: Azure-Governance-Solution-Presentation.pptx")
