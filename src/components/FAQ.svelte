<script lang="ts">
  import { slide } from 'svelte/transition';
  // FAQ data with questions and answers
  const faqItems = [
    {
      question: "What does PID mean?",
      answer: "PID stands for Proportional-Integral-Derivative controller. In simple terms, it's a smart, electronic temperature controller that keeps your machine's boiler at exactly the right heat"
    },
    {
      question: "What does 'plumbable' mean?",
      answer: "It means the espresso machine can be connected directly to your water line, so it fills itself. No need to keep refilling a water tank."
    },
    {
      question: "What is the average lifespan of an espresso machine?",
      answer: "Most home espresso machines last around 5–10 years with regular cleaning and good water. Cheaper models might wear out in 3–5 years, while high-end or commercial-style machines can run 15–20 years or more with proper care."
    },
    {
      question: "Is it worth getting an espresso machine with a built-in grinder?",
      answer: "If you want a simple, space-saving setup, an espresso machine with a built-in grinder can be a great choice. It's convenient and often more affordable than buying separate pieces. But if you care about getting the best grind quality, or want to upgrade later, a separate grinder is usually better. In short: built-in grinders are perfect for ease and everyday use, while separate setups give you more control and top-tier results."
    },
    {
      question: "What's the difference between a single boiler and a dual boiler?",
      answer: "A single boiler machine has one heater for both making espresso and steaming milk, so you have to wait between the two. A dual boiler has two heaters, so you can brew and steam at the same time."
    }
  ];

  // Track which FAQ item is open (only one at a time)
  let openIndex: number | null = null;

  function toggleItem(index: number) {
    openIndex = openIndex === index ? null : index;
  }
</script>

<section class="max-w-3xl mx-auto px-5 pb-8 py-12" itemscope itemtype="https://schema.org/FAQPage">
  <div class="text-center mb-12">
    <h2 class="font-serif font-bold text-primary text-2xl sm:text-4xl mb-4">
      Frequently Asked Questions
    </h2>
  </div>

  <div class="space-y-4">
    {#each faqItems as item, index}
      <div 
        class:bg-white={openIndex === index} 
        class="border-2 border-primary rounded-lg overflow-hidden"
        itemscope 
        itemprop="mainEntity" 
        itemtype="https://schema.org/Question"
      >
        <button
          class="w-full px-4 py-3 text-left bg-white/20 hover:bg-white transition-background duration-300 flex items-center justify-between"
          on:click={() => toggleItem(index)}
          aria-expanded={openIndex === index}
        >
          <h3 class="font-semibold text-gray-900 text-base sm:text-lg pr-4" itemprop="name">
            {item.question}
          </h3>
          <svg 
            class="w-5 h-5 text-gray-500 transform transition-transform duration-200 flex-shrink-0"
            class:rotate-[180deg]={openIndex === index}
            fill="none" 
            stroke="currentColor" 
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
          </svg>
        </button>
        
        {#if openIndex === index}
          <div 
            class="px-4 pb-4border-t border-gray-100 mb-4" 
            transition:slide={{ duration: 400, easing: t => t*t }}
            itemscope 
            itemprop="acceptedAnswer" 
            itemtype="https://schema.org/Answer"
          >
            <p class="text-gray-900 leading-relaxed" itemprop="text">
              {item.answer}
            </p>
          </div>
        {/if}
      </div>
    {/each}
  </div>
</section>

<style>
  .rotate-180 {
    transform: rotate(180deg);
  }
</style> 