
= Install =

  == Configure providers ==

    The platform integrates with multiple extenal resources.

    Note that each key can also be set in the codebase as a ruby global variable.

    Note that each key can also be set as an environment variable.

    The ruby global variable will override the environment variable. But the ruby global variable won't override the UI setting.

    === smtp ===

      _TODO: move to wco_email_rb setup.

      The default smtp relay is configured during installation and is not changeable via the UI. Ask your systems admin to do it for you.

      Then, the platform allows sending from, and receiving to, multiple email addresses. These are configured via smtp-enabled profiles. To effectively use this functionality, the email module must be enabled. Refer to the instructions in the email module for further steps.

    == OPENAI_API_KEY ==

      Note: OpenAI is not actually open.

      This key is required to enable the 'Rewrite' button. You can configure this key in the global settings:

      _TODO: well, I need these settings.

      \<>

= Use =

  == Functionality: AI writer ==

    Write the title of an article, push the button, and the article body will be written. Token usage fees apply.

    In effect, the article is generated from the title.

    This can be wired into larger workflows, including scraping other websites before, and publishing to other websites after.

    \<>

