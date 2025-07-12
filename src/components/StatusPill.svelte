<script lang="ts">
  export let value: boolean | string | null | undefined = false;

  $: isTrue = value === true || value === 'true' || `${value}`.toLowerCase() === 'yes';

  const baseClasses = "px-3 py-1 inline-flex text-xs leading-5 font-bold rounded-full border";

  $: statusClasses = isTrue
    ? 'bg-gradient-to-r from-green-100 to-emerald-100 text-black border-green-200'
    : 'bg-gradient-to-r from-gray-100 to-gray-200 text-gray-700 border-gray-300';
</script>

<span class="{baseClasses} {statusClasses}">
  {isTrue ? 'Yes' : 'No'}
</span> 