<?php

use App\Enums\EProjectState;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('projects', function (Blueprint $table) {
            $table->id();
            $table->timestamps();

            $table->string('name');
            $table->text('description')->nullable();
            $table->enum('state', EProjectState::values())->default(EProjectState::PLANNED->value);
            $table->boolean('is_public')->default(false);
            $table->date('start_date');
            $table->date('end_date');
            $table->unsignedInteger('budget')->nullable();
            $table->unsignedInteger('estimated_hours')->nullable();

            $table->foreignId('customer_id')
                ->constrained('customers')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('projects');
    }
};
